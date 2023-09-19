# 安装Docker
在chain目录下

```sh
$ make install-docker
```
# 获取SSL证书
在chain目录下

```sh
$ make install-acme
```

# 创建网络
## 下载工具

```sh
$ docker pull ethereum/client:alltools-latest
```
## 生成nodekey

```sh
$ docker run -it --rm ethereum/client-go:alltools-latest sh -c "bootnode -genkey tmp.key && cat tmp.key && echo"
```

会有想这样一串的密匙，`e5793dc60d802a0f40d4106fc4e74d197452a152de8c09a0942bd847115b1300`，以下称为nodekey

## 生成Validator密匙

```sh
$ docker run -it --rm -v ./keystores/validator-1:/datadir ethereum/client-go:alltools-latest sh -c "geth --datadir /datadir account new"
```

会被提示输入密码，以下是输出示例

```sh
INFO [09-18|15:39:26.249] Maximum peer count                       ETH=50 LES=0 total=50
INFO [09-18|15:39:26.252] Smartcard socket not found, disabling    err="stat /run/pcscd/pcscd.comm: no such file or directory"
Your new account is locked with a password. Please give a password. Do not forget this password.
Password: 
Repeat password: 

Your new key was generated

Public address of the key:   0x90d2E318B8CB7134a027CBFBbF242850629989A0
Path of the secret key file: /datadir/keystore/UTC--2023-09-18T15-39-38.966659960Z--90d2e318b8cb7134a027cbfbbf242850629989a0

- You can share your public address with anyone. Others need it to interact with you.
- You must NEVER share the secret key with anyone! The key controls access to your funds!
- You must BACKUP your key file! Without the key, it's impossible to access account funds!
- You must REMEMBER your password! Without the password, it's impossible to decrypt the key!
```

为每一个validator重复这个步骤，至少三个，五个最好

## 生成`genesis.json`
修改chain目录下的`config.json`

把刚才生成的validator的地址填入，`validators`和`initialStakes`下，`"0x3635c9adc5dea00000"`是1000，把你的主账户的地址放在`faucet`下， `"0x115EEC47F6CF7E35000000"`是21,000,000

删除chain目录下的`genesis.json`，在chain目录下

```sh
$ make create-genesis
```

请保存好生成的`genesis.json`

## 修改nodekey
在chain目录下的`docker-compose.yaml`, 改`bootnode`下nodekey为刚才生成的

```yaml
      - "--nodekeyhex=633ab917d09441de38ae9251e79ced41df39a1c338842b826c18fb1773246e18"
```

## 设置env

```sh
$ export DOMAIN_NAME=bitcoincode.technology
$ export CHAIN_ID=66666
$ export HOST_IP=`curl http://checkip.amazonaws.com`
```

## 运行bootnode
在chain目录下

```sh
$ make start-bootnode
```

## 获取bootnode的enode地址

```sh
$ docker exec -it bootnode sh -c "geth attach --exec admin.nodeInfo.enode /datadir/geth.ipc"
```

以下是输出示例

```sh
"enode://5c8e90050fabb7e14e4921dc107caf533140112245e7a231d0edc49861cd779760ad4804e7034952a5cc79422fa9d31c54e9a6141fb4995af7a6bfce7a39140f@44.211.79.220:30303"
```

## 修改validator
在chain目录下的`docker-compose.yaml`

改`validator_1`下

```yaml
      - "--unlock=0x08fae3885e299c24ff9841478eb946f41023ac69"
      - "--miner.etherbase=0x08fae3885e299c24ff9841478eb946f41023ac69"
      - "--bootnodes=enode://5c8e90050fabb7e14e4921dc107caf533140112245e7a231d0edc49861cd779760ad4804e7034952a5cc79422fa9d31c54e9a6141fb4995af7a6bfce7a39140f@bootnode.bitcoincode.technology:30303"
```

`--unlock`和`--miner.etherbase`是validator的地址

`--bootnodes`是刚刚的查找到的enode地址

```yaml
    volumes:
      - "./genesis.json:/datadir/genesis.json"
      - "./genesis/keystore:/datadir/keystore"
      - "./genesis/password.txt:/datadir/password.txt"
      - "./datadir/validator_1:/datadir/geth"
```

`./genesis/keystore`替换成刚才生成`./keystores/validator-1/keystore`

`./genesis/password.txt`替换保存刚才设置密码的文本文件，内容示例

```text
PASSWORD
```

`./datadir/validator_1`替换成指向validator-1的数据文件

按照这个改完所有validator

## 运行链
在chain目录下

```sh
$ make start
```

# Blockscout
## 运行blockscout
在blockscout/docker-compose目录下

```sh
$  docker compose up --detach --build
```
