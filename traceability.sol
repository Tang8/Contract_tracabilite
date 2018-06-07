pragma solidity ^0.4.2;
import "./owner.sol";

/** Subject 3 : Traceability
 **
 ** The idea is to make traceability of parts of a computer easier.
 ** Let's say we have a chain of different person, from the maker
 ** to the final user : every link of this chain will use the contract
 ** to testify state and even existence of the product.
**/

contract traceability_project {
    address private owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Used to set a state for the transaction
    enum State {IN_PROGRESS, APPROVED, DENIED}
    // Used to categorize comments about check (NTR = Nothing To Report)
    enum Comment {MISSING, FAULTY, WORN, NTR, OTHER}

    struct Product {
      uint id;
      string name;
      State state;
      string location;
      Comment comment;
    }

    struct People {
      address id;
      string name;
    }

    // Store products of the transaction
    mapping(uint => Product) public products;
    uint public productsCount;

    // Actors of the transaction
    mapping(uint => People) public peoples;
    uint public peopleCount = 0;

    // report event
    event checkedEvent (
        uint indexed peopleCount
    );

    function initialize () public {
        addPeople(0, "Seller");
        addPeople(1, "Deliverer");
        addPeople(2, "Buyer");
    }

    function addPeople (address _id, string _name) public {
        peoples[peopleCount] = People(_id, _name);
    }

    function addProduct (string _name, State def_state, Comment def_comment, string location) onlyOwner {
        productsCount ++;
        products[productsCount] = Product(productsCount, _name, def_state, location, def_comment);
        // At creation of the product, this latter is considered untouched.
        // There is no comment by default.
    }

    function check_progress () public returns(bool) {
      for (uint i = 0; i <= productsCount; i ++) {
        if (products[i].state != State.APPROVED)
          return false;
      }
      return true;
    }

    function modify_progress (uint _productId, State state, Comment comment) public {
        // check if currently authorized to interact
        require(peoples[peopleCount].id == msg.sender);

        // check if the product exists
        require(_productId > 0 && _productId <= productsCount);

        // update every pieces of information about the product
        //id name comment state.
        products[_productId].state = state;
        products[_productId].comment = comment;

        // check if every product is approved. If not, no event checked
        if (check_progress() == true) {
          peopleCount ++;
          checkedEvent(peopleCount);
        }
    }
}
