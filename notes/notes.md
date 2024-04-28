# 服务

`NFT` 交易市场开发需要多个服务，以下是需要的服务：

1. `IPFS` 服务，有两个端口：`8080` 和 `5001`；
2. `hardhat node`，提供以太坊区块链服务；
3. `Remix`：连接到`Remix`网页，端口`655xx`，不用关心端口，因为`Remix`与智能合约交互做的很好，很方便能够调用合约的函数；
4. 后端：`node.js`，端口在 `3000` 有两个接口，一个是上传文件，一个是`mint`需要的`NFT`；
5. 前端：`react`，·`3001`端口，对合约接口和后端接口，完成需要的功能。



# 智能合约

## 开发工具和环境

## 测试

- 测试代码应该是合约代码的3倍，测试驱动开发：`TDD`
- 能够有效降低开发者的心理负担；
- 需要具备问题拆分和代码设计能力；
- 红（未开发时不通过测试）➡绿（通过测试）➡重构（铜通过新功能后是否能够将旧的功能进行重构），

- 熟练之后可以先完成代码的大体框架，用remix跑通后再写测；
- 一定要明白测试最重要的是逻辑，要想到各种逻辑，最好用流程图画一下；

## 手撸合约思路

ERC-20

ERC-721

合约转账之前先授权；

查找一个人所有的NFT信息；

转账时候调用回调函数实现其他功能；

各种常用的回调函数

# 后端框架

NFT后端功能：接收用户`NFT`的图片、名称、描述，把图片上传到`IFDS`，返回图片的`URL`，然后再加上名称和描述组成`json`格式的`metedata`上传到`IPFS`，得到`metedata`的`URL`，然后调用`ERC-721`的`mint`函数进行铸造。本质上是先将图片上传到去中心化文件系统，然后再将其`URL`铸造到`ERC-721`合约中去，生成自己的代币。

1. `node`后端框架搭建；
   1. `node`后端项目理解：
      1. 项目初始化：`npm init -y`;
      2. 路由（相当于`Java`的`Spring MVC` 中的`HandlerMapping`，`node`的后端框架`express`）、中间件（文件存储`IPFS`）、模板引擎（`ejs`或者`pug`相当于`Java`的`JSP`）;
      3. 安装`express`、`ejs`、`kubo-rpc-client`（`IPFS`官方指定客户端）等`npm`包，这些组件都可以在`npm`官方上找到，并且可以查看其流行程度，点击官网看一下快速入门教程就可以上手使用，使用`npm i xxx`安装即可，安装的包都会在`package.json`中查看，`npm`相当于`Java`中的`Maven`项目管理工具；
      4. 为什么优先考虑用`node`开发，因为全栈工程师开发的话，前端和后端的写法很相似，有助于快速开发；
   2. 先在根目录写一个`js`文件，`app.js`，导入包并设置`ejs`，使用`express`构建`web`后端框架，然后写一个`get`测试根目录，检测`web`框架的可用性；
   3. 启动后端`node.js`命令：`node app.js`；将后端设置为热更新方式，安装`nodemon`，然后将`package.json`中的`scripts`中添加 `"start": "nodemon app.js"` 即可，然后 `npm run start`启动即可；
   4. 页面数据的获取`body-parser`和文件的获取`express-fileupload`去npmjs官网搜索，可以查看每个包当前的流行程度；
   5. 用配置文件的包：`dotenv`，然后新建一个`.env`文件，配置配置文件信息，然后将其添加到`.gitignore`中，防止私密信息上传到`git`；
   6. 本地起一个以太坊区块链 `npx hardhat node`，启动时会打印10个用户的地址和私钥；
2. 文件上传
   1. `IPFS`的实现，分布式文件系统，通过`hash`值进行查找，`P2P`网络；
   2. 将文件上传到 `IPFS`，因为上传文件的时候需要在后端保存一下才能上传到 `IPFS`，所以需要后端将文件在本地暂存一下才能继续上传`IPFS`；在本地文件夹，将前端收集到的文件放到文件中去，使用`node`自带的 `fs`移动，然后将文件上传到`IPFS`；
   3. 文件上传后会返回一个地址，根据这个地址可以访问到文件，将`NFT`的名称和描述以及文件的`URL`拼接的`MetaData`；为了开发方便，最好在本地安装`IPFS`，根据官网教程去安装即可，因为我的电脑是`windows`系统，`IPFS`需要`linux`系统环境，最好先安装一个`WSL`，
      1. 安装 `ws` ·，[适用于Windows的Linux子系统一一WSL安装使用教程](https://blog.csdn.net/dl962454/article/details/129757917)；
      2. 下载包，去`npfs`的官网上去找，用浏览器先下下来，然后再移动到`wsl`里面，wsl在网络里，安装，启动命令：`npfs daemon`；
      3. `IPFS`系统文件路径： `http://localhost:8080/ipfs/hash值/文件全名中查找`

3. `mint`一个`NFT`
   1. 前端使用`ethers.js`库，编写简单界面；
   2. 将 `ERC721`合约部署到本地以太坊区块链上；
   3. 导入`ERC-721`的`ABI`，调用合约的`mint`函数，将`URL`铸造到唯一的`token`中，得到`tokenId`，可以通过`balance`函数查询出自己有几个，然后`tokenOfOwnerBylndex` ，查询出`NFT`的`TokenID`，然后根据`id`查看其`URL`；

# 前端框架

## 代码示例

~~~react
import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

function MyComponent({ name }) {
  const [count, setCount] = useState(0);
  const nameChange = useEffect(() => {
    console.log('操作者发生变化，新操作者' + name);
  }, [name])

  const incrementCount = () => {
    setCount(count + 1);
  };

  return (
    <div>
      <p>{name} 点击了 {count} 次</p>
      <button onClick={incrementCount}>点</button>
    </div>
  );
}


function App() {
  // 状态：存储输入的名称
  const [name, setName] = useState('');
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <div>
          <MyComponent name={name} />
        </div>

        <div>
          {/* 输入框 */}
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Enter your name"
          />
        </div>
      </header>
    </div>
  );
}

export default App;

~~~

## 代码示例解释

1. 组件：一般写一个`function ` 组件名称，`{ return HTML }`，返回的是`HTML`，需要引用`ta`的话，就直接将这个组件名称放在`HTML`中即可，使用`<组件名称/>`即可；

2. `JSX`：在`js`里面写`HTML`，直接返回，一种新的写前端方式，基于逻辑的，`HTML`和`css`都是嵌入在`js`中的，一切都由`js`操作；

3. 状态管理

   1. 本质上是 `React` 有一个基类 `Component` ，就是`Java`里面的`Object`一样，成员变量、结构体（初始化成员变量）和`setXXX()`函数，当`setXXX`时就会对成员变量进行修改，成员变量和`setXXX`函数需要自己指定

      ~~~react
      import React, { Component } from 'react';
      
      class MyComponent extends Component {
        constructor(props) {
          super(props);
          this.state = {
            count: 0
          };
        }
      
        incrementCount() {
          this.setState({ count: this.state.count + 1 });
        }
      
        render() {
          return (
            <div>
              <p>Count: {this.state.count}</p>
              <button onClick={() => this.incrementCount()}>Increment</button>
            </div>
          );
        }
      }
      
      //在其他组件的HTML中调用该组件即可：
      //        <div>
      //          <MyComponent name="中本聪" />
      //        </div>
      
      ~~~

      使用函数表达式方式：`useState(0)`初始化；`count`成员变量；`setCount()`函数

      ~~~react
      import React, { useState } from 'react';
      
      function MyComponent() {
        const [count, setCount] = useState(0);
      
        const incrementCount = () => {
          setCount(count + 1);
        };
      
        return (
          <div>
            <p>Count: {count}</p>
            <button onClick={incrementCount}>Increment</button>
          </div>
        );
      }
      
      ~~~

4. 属性传递：父组件向子组件传递值，谁点击了按钮几次，父组件输入名字，子组件记录点击次数；

5. 其他的常用函数：当一个值发生改变的时候，去渲染页面；需要引用：`useEffect`，相当于一个钩子函数（回调函数），实现的功能是当名字发生改变的时候，打印出来；


## 前端框架搭建

使用`wagmi`前端框架会更加方便（本项目中未使用），因为不精通前端，这里只是简单的搭建了`react`前端框架实现这些功能；

1. 智能合约交互，安装`ether,js`，根据`ABI`和合约地址就可以调用合约中的函数；
2. 将智能合约的`ABI`放在`contracts`文件下统一管理，然后封装合约中的方法，在`util`文件夹下统一管理；
3. 将前端组件放在`components`下统一管理，然后写前端逻辑就可以了；
4. 依赖包：
   1. `react`，前端框架；
   2. `ether.js`：智能合约交互；
   3. `react-router-dom`，路由上传完成后跳转到上传完成的页面`URL`；
   4. `axios`:`HTTP`客户端，相当于`ajax`;

## 构建页面和逻辑

### 导航条

有以下几个：

- 钱包地址显示和连接
- 首页
- 铸造`NFT`
- 我的`NFT`，上架功能（待补充）

### 钱包地址

1. 先添加一个连接钱包的导航条，`Navbar`组件，使用
2. 检查浏览器是否安装了钱包插件，判断 `window.ethereum` 是否为空，得到目前钱包的区块链地址；
3. 定义变量，目前小狐狸中的钱包地址；点击绑定钱包，来绑定地址，值的传递；
5. 切换地址时候，前端中加载的地址发生动态改变；

### NFT Card 组件

根据`NFT`的`tokenId`加载`NFT`图片、名称和价格。

### NFT 市场首页

首页展示展示所有合约交易市场中所有的`NFT`的图片、名称和价格，利用`NFT Card`组件，点击首页的图片时进行跳转到NFT详情页。

### NFT 详情页面

`NFT`图片、名称、描述、价格、出售者、tokenId。

### 铸造 NFT 页面

用户添加`NFT`名称、描述、图片，然后进行铸造；页面就是后端实现的前端页面一样，只不过增加了一个取消按钮，取消后所有属性回归到初始状态，其他逻辑没有变。

# 使用流程

1. 打开`NFT`交易市场首页，连接钱包；
2. 打开铸造页面，进行铸造 `NFT`；可以 `mint` 多个，可以在`ERC-721`合约中查询；
3. 上架，本质上就是将自己的`NFT`转移到`Market`合约中，在这个过程会触发`Market`合约的 `onERC721Received`函数，最终保存在`Market`合约的账本上（合约中的成员变量），具体分为以下两个流程：
   1. 授权，将自己要出售的`NFT`授权给`Market`合约，无论是非同质化代币还是同质化代币，都需要在转帐前先授权，可以先通过 `balance`查询出自己有几个，然后 通过`tokenOfOwnerBylndex`，查询出`NFT`的`tokenID`，然后将 `tokenId` 授权给`Market`合约；
   2. 转账，目前使用的`ERC-721`中的 `safeTransferFrom` 四个参数的函数，最终一个参数填写价格（这个价格是编码后的）;
4. 购买，用买`Market`合约中指定的`ERC-20`代币进行购买，购买的时候先确保自己足够的代币，然后先授权，再调用`Market`合约中的购买函数转账即可，可以在`ERC-721`合约中查询；

