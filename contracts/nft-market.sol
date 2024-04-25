// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract NFTMarket is IERC721Receiver {
    //定义构造函数，传入ERC20和ERC721合约地址

    IERC20 public immutable erc20;
    IERC721 public immutable erc721;

    struct Order {
        address seller;
        uint256 tokenId;
        uint256 price;
    }

    mapping(uint256 => Order) public orderOfTokenId; //   tokenId to order
    Order[] public orders; // order list ；便于遍历获取所有订单
    mapping(uint256 => uint256) public orderIndexOfTokenId; // tokenId to order index；根据数组中 orders 的位序来映射 tokenId，从而操作 orders，从而维护 orderOfTokenId 和 orders 数据的一致性
    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    constructor(address _erc20, address _erc721) {
        //检测传入的ERC20和ERC721合约地址是否有效
        require(_erc20 != address(0), "Invalid ERC-20 contract address");
        require(_erc721 != address(0), "Invalid ERC-721 contract address");
        erc20 = IERC20(_erc20);
        erc721 = IERC721(_erc721);
    }

    //新建订单事件
    event NewOrder(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );
    //取消订单事件
    event CancelOrder(address indexed seller, uint256 indexed tokenId);
    //订单修改价格事件
    event UpdateOrderPrice(
        address indexed seller,
        uint256 indexed tokenId,
        uint256 oldPrice,
        uint256 newPrice
    );
    //订单成交事件
    event OrderDeal(
        address indexed buyer,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );

    //购买
    function buy(uint256 tokenId) external {
        require(isListed(tokenId), "Market: Token ID is not listed");
        //获取订单
        Order storage order = orderOfTokenId[tokenId];
        address seller = order.seller;
        address buyer = msg.sender;
        uint256 price = order.price;

        //检测购买者是否有足够的ERC20代币
        require(erc20.balanceOf(buyer) >= price, "Insufficient ERC-20 balance");
        //执行交易
        erc20.transferFrom(buyer, seller, price);
        erc721.safeTransferFrom(address(this), buyer, tokenId);
        //删除订单
        removeListing(tokenId);
        //触发订单成交事件
        emit OrderDeal(msg.sender, order.seller, tokenId, order.price);
    }

    //当用户将ERC20代币发送到合约时，执行此函数；新建订单
    //在NFT 合约上调用 safeTransferFrom 函数时，会自动调用本方法，用户只需要往本合约中转账即可上架 NFT

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        uint price = toUint256(data, 0);
        //检测价格是否有效
        require(price > 0, "Invalid price");
        //验证操作者的权限
        require(operator == from, "Invalid operator");
        //新建订单
        orderOfTokenId[tokenId] = Order(from, tokenId, price);

        orders.push(orderOfTokenId[tokenId]);
        orderIndexOfTokenId[tokenId] = orders.length - 1;

        emit NewOrder(from, tokenId, price);
        return MAGIC_ON_ERC721_RECEIVED;
    }

    //取消订单
    function cancel(uint256 tokenId) external {
        //获取订单
        Order storage order = orderOfTokenId[tokenId];
        //检测订单是否存在
        require(order.seller != address(0), "Order does not exist");
        //检测订单是否属于调用者
        require(order.seller == msg.sender, "Not the owner of the order");
        //删除订单
        removeListing(tokenId);
        //触发取消订单事件
        emit CancelOrder(msg.sender, tokenId);
    }

    //修改订单价格
    function updatePrice(uint256 _tokenId, uint256 newPrice) external {
        //检测订单是否存在
        require(isListed(_tokenId), "Market: Token ID is not listed");
        //获取订单
        Order storage order = orderOfTokenId[_tokenId];
        uint256 oldPrice = order.price;
        //检测订单是否属于调用者
        require(order.seller == msg.sender, "Not the owner of the order");
        //检测新价格是否有效
        require(newPrice > 0, "Invalid price");
        //更新订单价格
        order.price = newPrice;
        Order storage o = orders[orderIndexOfTokenId[_tokenId]];
        o.price = newPrice;
        //触发订单修改价格事件
        emit UpdateOrderPrice(msg.sender, _tokenId, oldPrice, newPrice);
    }

    //查询所有订单
    function getAllNFTs() external view returns (Order[] memory) {
        return orders;
    }

    //查询指定 tokenId 是否已经上架
    function isListed(uint256 _tokenId) public view returns (bool) {
        return orderOfTokenId[_tokenId].seller != address(0);
    }

    //查询订单的数量
    function getOrderLength() public view returns (uint256) {
        return orders.length;
    }

    //查询指定 tokenId 的订单
    function getOrderByTokenId(
        uint256 tokenId
    ) external view returns (Order memory) {
        require(
            orderOfTokenId[tokenId].seller != address(0),
            "Order does not exist"
        );
        return orderOfTokenId[tokenId];
    }

    //查询属于自己的 NFT 订单
    function getMyNFTs() public view returns (Order[] memory) {
        Order[] memory myOrders = new Order[](orders.length);
        uint256 myOrdersCount = 0;

        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i].seller == msg.sender) {
                myOrders[myOrdersCount] = orders[i];
                myOrdersCount++;
            }
        }

        Order[] memory myOrdersTrimmed = new Order[](myOrdersCount);
        for (uint256 i = 0; i < myOrdersCount; i++) {
            myOrdersTrimmed[i] = myOrders[i];
        }

        return myOrdersTrimmed;
    }

    //删除数据后，更新帐本
    function removeListing(uint256 _tokenId) internal {
        delete orderOfTokenId[_tokenId];

        uint256 orderToRemoveIndex = orderIndexOfTokenId[_tokenId];
        uint256 lastOrderIndex = orders.length - 1;

        if (lastOrderIndex != orderToRemoveIndex) {
            Order memory lastOrder = orders[lastOrderIndex];
            orders[orderToRemoveIndex] = lastOrder;
            orderIndexOfTokenId[lastOrder.tokenId] = orderToRemoveIndex;
        }

        orders.pop();
    }

    //将byte4的数字转化为 uint256 格式
    // https://stackoverflow.com/questions/63252057/how-to-use-bytestouint-function-in-solidity-the-one-with-assembly
    function toUint256(
        bytes memory _bytes,
        uint256 _start
    ) public pure returns (uint256) {
        require(_start + 32 >= _start, "Market: toUint256_overflow");
        require(_bytes.length >= _start + 32, "Market: toUint256_outOfBounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
}
