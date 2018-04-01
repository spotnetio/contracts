pragma solidity ^0.4.19;

import "./ERC20.sol";
import "./math.sol";

contract Spot is DSMath{
	struct lock{
		address		lender;
		address		borrower;
		uint 		amountX1;
		uint		amountEther; 
	}
	mapping (address => lock[]) locks;

	address WEth = address(0x0); // Weth address here

	event Log(uint a);

	function Lock(
		address token, 
		address lender, 
		address	borrower,	// WETH address
		uint	ethAmount,
		uint 	rate,		// times 100
		uint 	fee,		// basis (10000)
		uint 	margin		// basis
	) public {
		require(rate != 0);
		require(ethAmount > 0);
		uint x1Amount = 1000000*ethAmount/(rate*(fee + margin));
		locks[token].push(lock(
			lender, 
			borrower, 
			x1Amount, 
			ethAmount
		));
		// Transfer WETH from borrower to this		
		ERC20(WEth).transferFrom(
			borrower, 
			this,
			ethAmount
		);
		// Transfer base to borrower
		ERC20(token).transferFrom(
			lender,
			borrower, 
			x1Amount
		);
	}
	
	function BuyToCover(
		address token, 
		address borrower,
		uint 	rate,		// percent 	(100)
		uint 	fee,		// basis 	(10000)
		uint 	margin		// basis	(10000)
	) public {
		lock[] storage locksForToken = locks[token];
		for (uint i=0; i<locksForToken.length; i++) {
			if (locksForToken[i].borrower == msg.sender) {
				require (ERC20(token).allowance(msg.sender, this) >= locksForToken[i].amountX1);
				ERC20(token).transferFrom(
					msg.sender, 
					locksForToken[i].lender, 
					locksForToken[i].amountX1
				);
				// Transfer WETH to borrower from this		
				ERC20(WEth).transfer(
					borrower, 
					locksForToken[i].amountX1*rate*(fee + margin)/1000000
				);
				delete locksForToken[i]; // TODO: implement linked list
			}
		}
	}

	function SwapLenders(
		address 	token, 
		address		lender,
		address[]	lenders,
		uint 		rate,		// percent 	(100)
		uint 		fee,		// basis 	(10000)
		uint 		margin		// basis		(10000)) 
	) public {
		lock[] storage locksForToken = locks[token];
		for (uint i=0; i<locksForToken.length; i++) {
			if (locksForToken[i].lender == lender) {
				for (uint j=0; j<lenders.length; j++) {
					uint allowance = ERC20(token).allowance(
						lenders[j], 
						this
					);
					if (allowance > 0) {
						uint x1ToTransfer = min(allowance, locksForToken[i].amountX1);
						uint etherToTransfer = x1ToTransfer*rate*(fee + margin)/1000000;
						locksForToken[i].amountX1 -= x1ToTransfer;
						locksForToken[i].amountEther -= etherToTransfer;
						locks[token].push(lock(
							lenders[j], 
							locksForToken[i].borrower, 
							x1ToTransfer, 
							etherToTransfer
						));
						// Transfer X1 from new lender to old
						ERC20(token).transferFrom(
							lenders[j], 
							lender, 
							x1ToTransfer
						);
					}
				}
			}
		}
	}

	function MarginCall(
		address token,
		address borrower,
		bytes32 r, 
		bytes32 s,
		uint8 	v, 
		uint 	rate,		// percent 	(100)
		uint 	fee,		// basis 	(10000)
		uint 	margin		// basis	(10000)) 
	) public {
		bytes32 message = keccak256(rate + fee + margin);
		require(ecrecover(message, v, r, s) == address(0x0)); // Oracle address here
		lock[] storage locksForToken = locks[token];
		for (uint i=0; i<locksForToken.length; i++) {
			if (locksForToken[i].borrower == borrower) {
				if(locksForToken[i].amountEther < locksForToken[i].amountX1*rate*(fee + margin)/1000000) {
					// Send Ether to lender
					ERC20(WEth).transfer(
						locksForToken[i].lender, 
						locksForToken[i].amountEther
					);
					delete locksForToken[i];
				}
			}
		}
	}

	function getLock(
		address token, 
		address lender, 
		address borrower
	) public view returns (uint, uint) {
		uint x1Amount;
		uint etherAmount;
		lock[] storage locksForToken = locks[token];
		for (uint i=0; i<locksForToken.length; i++) {
			if (locksForToken[i].lender == lender && locksForToken[i].borrower == borrower) {
				x1Amount += locksForToken[i].amountX1;
				etherAmount += locksForToken[i].amountEther;
			}
		}
		return (x1Amount, etherAmount);
	}

	function getLockLender(
		address token, 
		address lender
	) public view returns (uint) {
		uint x1Amount;
		lock[] storage locksForToken = locks[token];
		for (uint i=0; i<locksForToken.length; i++) {
			if (locksForToken[i].lender == lender) {
				x1Amount += locksForToken[i].amountX1;
			}
		}
		return x1Amount;
	}
}

















