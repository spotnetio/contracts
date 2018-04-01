pragma solidity ^0.4.18;

contract Counterpart {
	bool initialized;
	mapping (uint => node) nodes;
	node root;
	struct node {
		uint	id;
		uint 	prev;
		uint 	next;
		address co;
		uint 	amount;
	}
	function Counterpart() public {initialized = true;}
	function isInitialized() public view returns (bool) { return initialized;}
	function addCounterpart(address co, uint amount) public {
		node memory n = node(root.id+1, 0, root.id, co, amount);
		root.prev = n.id;
		root = n;
		nodes[root.id] = root;
	}
	function removeCounterpart(uint id) public {
		node memory n = nodes[id];
		nodes[n.prev].next = n.next;
		nodes[n.next].prev = n.prev;
		if (root.id == id) {
			root = nodes[n.next];
		}
	}
	function getCounterpart(uint id) public view returns (address, uint) {
		return (nodes[id].co, nodes[id].amount);
	}
}