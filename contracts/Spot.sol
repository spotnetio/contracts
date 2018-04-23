pragma solidity ^0.4.19;

import "./ERC20.sol";
import "./math.sol";

contract Spot is DSMath{
	address[]	borrowers;
	uint 		public borrLength;
	address[] 	tokens;
	uint[]		amountEther; 
	address[][]	lenders;
	uint[][]	amounts;
	uint[] 		lendLength;
	uint[] 		createdAt;

	event Log(uint a);

	function getTraders() public view returns (address[]) {
		return borrowers;
	}
	function getTokens() public view returns (address[]) {
		return tokens;
	}
	function getTradersAmounts() public view returns (uint[]) {
		return amountEther;
	}	
	function getLenders(uint idx) public view returns (address[]) {
		return lenders[idx];
	}	
	function getAmounts(uint idx) public view returns (uint[]) {
		return amounts[idx];
	}	
	function getAmount(uint idx, uint idx2) public view returns (uint) {
		return amounts[idx][idx2];
	}
	function getBorrowersLength() public view returns (uint) {
		return borrLength;
	}
	function getLendLength(uint idx) public view returns (uint) {
		return lendLength[idx];
	}	

	function Lock(
		address	borrower,
		int 	borrTokIdx,
		address token, 	
		uint	x1Amount,
		address lender,
		int 	lenderIdx,
		uint 	rate,		// times 100
		uint 	fee,		// basis (10000)
		uint 	margin		// basis
	) public {
		require(rate != 0);
		require(x1Amount > 0);
		uint ethAmount = x1Amount*rate*(fee + margin)/1000000;
		if (borrTokIdx == -1) {
			addBorrowerLock(
				borrower,
				token, 	
				ethAmount,
				lender,
				x1Amount
			);
		}
		else {
			amountEther[uint(borrTokIdx)] += ethAmount;
			addLender(
				uint(borrTokIdx),
				lender,
				x1Amount,
				lenderIdx
			);
		}

		// Transfer WETH from borrower to this		
		// ERC20(WEth).transferFrom(
		// 	borrower, 
		// 	this,
		// 	ethAmount
		// );
		// // Transfer base to borrower
		// ERC20(token).transferFrom(
		// 	lender,
		// 	borrower, 
		// 	x1Amount
		// );
	}
	
	function BuyToCover(
		uint borrTokIdx, 
		uint amount,
		uint rate,		// percent 	(100)
		uint fee,		// basis 	(10000)
		uint margin		// basis	(10000)
	) public {
		for (uint i=0; i<lendLength[borrTokIdx]; i++) {
			if(amount >= amounts[borrTokIdx][i]) {
				// TODO: Transfer to lender amounts[borrTokIdx][i] 
				deleteLender(borrTokIdx, i);
			}
			else {
				// TODO: Transfer to lender amount
				amounts[borrTokIdx][i] -= amount;
			}
		}
		if (lendLength[borrTokIdx] == 0) {
			deleteBorrowerLock(borrTokIdx);
		}
		amountEther[borrTokIdx] -= amount*rate*(fee + margin)/1000000;
		// TODO: Transfer funds to trader
	}

	event Swapped();
	function Swap(
		uint[]		borrTokIdx,
		uint[]		lenderIdx,
		address[] 	newLenders,
		int[]		newLendersIdx,
		uint[] 		amts
	) public {
		for (uint i=0; i<borrTokIdx.length; i++) {
			for (uint j=0; j<newLenders.length; j++) {
				uint lockedAmt = amounts[borrTokIdx[i]][lenderIdx[i]];
				if (amts[j] >= lockedAmt) {				
					addLender(
						borrTokIdx[i],
						newLenders[j],
						lockedAmt,
						newLendersIdx[j]
					);
					deleteLender(
						borrTokIdx[i],
						lenderIdx[i]
					);	
					amts[j] -= lockedAmt;
					// TODO: Transfer X1 
					break;
				}
				else {
					addLender(
						borrTokIdx[i],
						newLenders[j],
						amts[j],
						newLendersIdx[j]
					);
					amounts[borrTokIdx[i]][lenderIdx[i]] -= amts[j];
					delete amts[j];
					// TODO: Transfer X1 
				}
			}
		}
		Swapped();
	}

	function Recall(
		uint[]		borrTokIdx,
		uint[]		lenderIdx,
		uint[] 		amts
	) public {
		for(uint i=0; i<borrTokIdx.length; i++){
			deleteLender(borrTokIdx[i], lenderIdx[i]);
			// TODO: Transfer funds to lender & borrower
		}
	}

	// function MarginCall(
	// 	address token,
	// 	address borrower,
	// 	bytes32 r, 
	// 	bytes32 s,
	// 	uint8 	v, 
	// 	uint 	rate,		// percent 	(100)
	// 	uint 	fee,		// basis 	(10000)
	// 	uint 	margin		// basis	(10000)) 
	// ) public {
	// 	bytes32 message = keccak256(rate + fee + margin);
	// 	require(ecrecover(message, v, r, s) == address(0x0)); // Oracle address here
	// }

	address[] lenderArr;
	uint[] amtArr;
	function addBorrowerLock(
		address	borrower,
		address token, 	
		uint	ethAmount,
		address lender,
		uint 	x1Amount
	) internal {
		lenderArr.push(lender);
		amtArr.push(x1Amount);
		if (borrowers.length > borrLength) {
			borrowers[borrLength] = borrower;
			tokens[borrLength] = token;
			amountEther[borrLength] = ethAmount;
			lenders[borrLength] = lenderArr;
			amounts[borrLength] = amtArr;
			lendLength[borrLength] = 1;
			createdAt[borrLength] = now;
		}
		else {
			borrowers.push(borrower);
			tokens.push(token);
			amountEther.push(ethAmount);
			lenders.push(lenderArr);
			amounts.push(amtArr);
			lendLength.push(1);
			createdAt.push(now);			
		}
		borrLength += 1;
	}

	function addLender(
		uint 	borrTokIdx,
		address lender,
		uint 	x1Amount,
		int 	lenderIdx
	) internal {
		if (lenderIdx >= 0) {
			amounts[borrTokIdx][uint(lenderIdx)] += x1Amount;
		}
		else {
			if (lenders[borrTokIdx].length > lendLength[borrTokIdx]) {
				lenders[borrTokIdx][lendLength[borrTokIdx]] = lender;
				amounts[borrTokIdx][lendLength[borrTokIdx]] = x1Amount;
			}
			else {
				lenders[borrTokIdx].push(lender);
				amounts[borrTokIdx].push(x1Amount);
			}
			lendLength[borrTokIdx] += 1;
		}
	}

	function deleteLender(
		uint 	borrTokIdx,
		uint 	lIdx
	) internal {
		uint lastIdx = lendLength[borrTokIdx]-1;
		lenders[borrTokIdx][lIdx] = lenders[borrTokIdx][lastIdx];
		amounts[borrTokIdx][lIdx] = amounts[borrTokIdx][lastIdx];
		lendLength[borrTokIdx] -= 1;
		if(lendLength[borrTokIdx] == 0) {
			deleteBorrowerLock(borrTokIdx);
		}
	}

	function deleteBorrowerLock(
		uint 	borrTokIdx
	) internal {
		uint lastIdx = borrLength-1;
		borrowers[borrTokIdx] = borrowers[lastIdx];
		tokens[borrTokIdx] = tokens[lastIdx];
		amountEther[borrTokIdx] = amountEther[lastIdx];
		lenders[borrTokIdx] = lenders[lastIdx];
		amounts[borrTokIdx] = amounts[lastIdx];
		lendLength[borrTokIdx] = lendLength[lastIdx];
		createdAt[borrTokIdx] = createdAt[lastIdx];
		borrLength -= 1;
	}
}
