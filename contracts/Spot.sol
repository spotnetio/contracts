pragma solidity ^0.4.19;

import "./ERC20.sol";
import "./math.sol";

contract Spot is DSMath{
	address[]	borrowers;
	address[] 	tokens;
	uint[]		amountEther; 
	address[][]	lenders;
	uint[][]	amounts;
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
	
	// function BuyToCover(
	// 	uint borrTokIdx, 
	// 	uint amount,
	// 	uint rate,		// percent 	(100)
	// 	uint fee,		// basis 	(10000)
	// 	uint margin		// basis	(10000)
	// ) public {
	// 	for (uint i=0; i<lendLength[borrTokIdx]; i++) {
	// 		if(amount >= amounts[borrTokIdx][i]) {
	// 			// TODO: Transfer to lender amounts[borrTokIdx][i] 
	// 			amounts[borrTokIdx][i] = 0;
	// 		}
	// 		else {
	// 			// TODO: Transfer to lender amount
	// 			amounts[borrTokIdx][i] -= amount;
	// 		}
	// 	}
	// 	if (lendLength[borrTokIdx] == 0) {
	// 		deleteBorrowerLock(borrTokIdx);
	// 	}
	// 	amountEther[borrTokIdx] -= amount*rate*(fee + margin)/1000000;
	// 	// TODO: Transfer funds to trader
	// }

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
					amounts[borrTokIdx[i]][lenderIdx[i]] = 0;	
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
			amounts[borrTokIdx[i]][lenderIdx[i]] -= min(
				amounts[borrTokIdx[i]][lenderIdx[i]],
				amts[i]
			);
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

	function addBorrowerLock(
		address	borrower,
		address token, 	
		uint	ethAmount,
		address lender,
		uint 	x1Amount
	) internal {
		borrowers.push(borrower);
		tokens.push(token);
		amountEther.push(ethAmount);
		createdAt.push(now);
		address[] memory lenderArr = new address[](1);
		uint[] memory amtArr = new uint[](1);
		lenderArr[0] = lender;
		amtArr[0] = x1Amount;
		lenders.push(lenderArr);
		amounts.push(amtArr);			
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
			lenders[borrTokIdx].push(lender);
			amounts[borrTokIdx].push(x1Amount);
		}
	}
}
