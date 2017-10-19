pragma solidity 0.4.17;
contract Ownable {
    address public owner;

    function Ownable() { //This call only first time when contract deployed by person
        owner = msg.sender;
    }
    modifier onlyOwner() { //This modifier is for checking owner is calling
        if (owner == msg.sender) {
            _;
        } else {
            revert();
        }

    }
    

}

contract Mortal is Ownable {
    
    function kill() {
        if (msg.sender == owner)
            selfdestruct(owner);
    }
}

contract Token {
    uint256 public totalSupply;
    uint256 limitYearTime;
    uint256 tokensReserve;

    function balanceOf(address _owner) constant returns(uint256 balance);

    function transfer(address _to, uint256 _tokens) public returns(bool resultTransfer);

    function transferFrom(address _from, address _to, uint256 _tokens) public returns(bool resultTransfer);

    function approve(address _spender, uint _value) returns(bool success);

    function allowance(address _owner, address _spender) constant returns(uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event TransferSHP( address indexed _to, uint256 _value);
}
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
}
contract StandardToken is Token,Mortal,Pausable {
    
    modifier reserveTokensCheck(uint256 _values){
        require(_values>0);
        if(msg.sender == owner){
             if (balances[msg.sender] < _values) {
                 revert();
             }
            uint256 tokensAfterTransfer=balances[owner]-_values;
            if(now<limitYearTime && tokensAfterTransfer<tokensReserve){
                revert();
            }else{
                _;
            }
        }else{
            _;
        }
    }
    
    function transfer(address _to, uint256 _value) whenNotPaused reserveTokensCheck(_value) 
    returns (bool success) {
        require(_to!=0x0);
        require(_value>0);
         if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            TransferSHP(_to,balances[_to]);
            TransferSHP(msg.sender,balances[msg.sender]);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 totalTokensToTransfer)whenNotPaused returns (bool success) {
        require(_from!=0x0);
        require(_to!=0x0);
        require(totalTokensToTransfer>0);
    
       if (balances[_from] >= totalTokensToTransfer&&allowance(_from,_to)>=totalTokensToTransfer) {
            balances[_to] += totalTokensToTransfer;
            balances[_from] -= totalTokensToTransfer;
            allowed[_from][msg.sender] -= totalTokensToTransfer;
            Transfer(_from, _to, totalTokensToTransfer);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balanceOfUser) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
contract Synthium is StandardToken{
    string public constant name = "Synthium Platform Token";
    uint public constant decimals = 18;
    string public constant symbol = "SHP";
    
    function Synthium(){
       totalSupply=1000000000 *(10**18);  //One Billion
       owner = msg.sender;
       balances[msg.sender] = totalSupply;
       limitYearTime=now+1 *1 years;
       tokensReserve=150000000*(10**18);
       
    }
    function resetTokenOfAddress(address _userAdd) onlyOwner {
        require(_userAdd != 0x0);
       uint256 userToken= balances[_userAdd] ;
       require(userToken>0);
        balances[_userAdd] -= userToken;
        balances[owner] += userToken;
        Transfer(_userAdd, owner, userToken);
    }
    function(){
        revert();
    }
}