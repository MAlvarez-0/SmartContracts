//SPDX-License-Identifier: UNLICENSED


pragma solidity 0.8.10;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);
  
  function swapExactTokensForTokens(

    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;
}

interface IUniswapV2Factory {
  function getPair(address token0, address token1) external returns (address);
}




contract Swap {

    address owner; 
    address public uniswapRouter; // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D UNISWAP V2 ROUTER 
    mapping(address => uint) public tokensBalance;

    constructor(address _routerAddress) {
        owner = msg.sender;
        uniswapRouter = _routerAddress;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }


    function getBalance(address _token) internal view returns(uint) {
      return(IERC20(_token).balanceOf(msg.sender));
    }

    //Deposit tokens
    function deposit(address _token, uint _amount) internal isOwner {
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount));
        
    }
    function withdraw(address _token, uint _amount) external isOwner {
        require(getBalance(_token) >= _amount, 'Amount exceed balance' );
        IERC20(_token).transfer(msg.sender, _amount);
    }
    //////////////



    //Swap 
    function swap(address _token1, address _token2, uint256 _amountIn) external isOwner {

        uint256 amountOutMin = getAmountOutMin(_token1, _token2, _amountIn);
        address _to = address(this); 

        IERC20(_token1).approve(uniswapRouter, _amountIn);

        address[] memory path;
          
        path = new address[](2);
        path[0] = _token1;
        path[1] = _token2;
          
        IUniswapV2Router(uniswapRouter).swapExactTokensForTokens(_amountIn, amountOutMin, path, _to, block.timestamp);

    }


    function getAmountOutMin(address _tokenIn, address _tokenOut, uint256 _amountIn) internal view returns (uint256) {

        address[] memory path;
        
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        
        
        uint256[] memory amountOutMins = IUniswapV2Router(uniswapRouter).getAmountsOut(_amountIn, path);
        return amountOutMins[path.length -1];  
    }  
    ////////////////////////////
}