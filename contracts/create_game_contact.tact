import "@stdlib/deploy";
import "@stdlib/ownable";
struct GameData {
    gameOwnerAddress: Address;
    activePlayerCount: Int as uint32;
    totalSpots: Int as uint32;
    totalRewardPool: Int as uint256;
    entryFee: Int as uint32;
    gameStatus: Int as uint32;
    gameDurationSeconds: Int as uint256;
    activePlayers: map<Address, Int as uint256>;
    createdAt: Int as uint256;
    startedAt: Int as uint256;
    completedAt: Int as uint256;
}
struct CreateGameRequest {
    gameId: Int as uint256;
    totalSpots: Int as uint32;
    totalRewardPool: Int as uint256;
    entryFee: Int as uint32;
    gameDurationSeconds: Int as uint256;
}
struct TestStructure {
    data1: Int as uint256;
    data2: Int as uint256;
}
struct CreateStruct {
    value1: Int as uint256;
    value2: Int as uint256;
    value3: Address;
    time: Int as uint256;
}
struct Test {
    address: Address;
    time: Int as uint256;
    recievedData: Int as uint256;
}
message CreateGameRequestMessage {
    gameId: Int as uint256;
    totalSpots: Int as uint32;
    totalRewardPool: Int as uint256;
    entryFee: Int as uint32;
    gameDurationSeconds: Int as uint256;
}
message SetTestData {
    value1: Int as uint256;
    value2: Int as uint256;
}
message SetStructureToMap {
    set1: TestStructure;
}
message SetTestToMap {
    key: Int as uint256;
    value: Int as uint256;
}
message SetMap {
    gameId: Int as uint256;
}

contract CreateGameContact with Deployable, Ownable {
    owner: Address;
    const GameListed: Int = 0;
    const GameLive: Int = 1;
    const GameCompleted: Int = 2;
    const GameCancelled: Int = 3;
    gameList: map<Int as uint256, GameData>;
    testData: map<Int as uint256, Int as uint256>;
    testStruct: map<Int as uint256, CreateStruct>;
    testMap: map<Int as uint256, GameData>;
    testingMap: map<Int as uint256, Test>;
    init(){
        self.owner = sender();
        // emit(OnGameContractDeployed{contractAddress: myAddress(),transaction_by: sender()}.toCell());
    }

    receive(msg: SetTestData){
        self.testData.set(msg.value1, msg.value2);
    }

    receive(msg: SetStructureToMap){
        // self.reply({formData}.toCell());
        self.testStruct.set(msg.set1.data1,
            CreateStruct{value1: 2500, value2: msg.set1.data2, value3: sender(), time: now()}
        );
    }

    receive(msg: SetTestToMap){
        // let formData: Test = {
        //     address:sender(),
        //     time:now(),
        // };
        // self.reply({formData}.toCell());
        self.testingMap.set(msg.key, Test{address: sender(), time: now(), recievedData: msg.value});
    }

    receive(msg: CreateGameRequestMessage){
        self.requireOwner();
        self.gameList.set(msg.gameId,
            GameData{
                gameOwnerAddress: sender(),
                activePlayerCount: 0,
                totalSpots: msg.totalSpots,
                totalRewardPool: msg.totalRewardPool,
                entryFee: msg.entryFee,
                gameStatus: self.GameListed,
                gameDurationSeconds: msg.gameDurationSeconds,
                activePlayers: emptyMap(),
                createdAt: 0,
                startedAt: 0,
                completedAt: 0
            }
        );
        self.reply("Creating Game".asComment());
    }

    receive(msg: SetMap){
        self.testMap.set(msg.gameId,
            GameData{
                gameOwnerAddress: sender(),
                activePlayerCount: 0,
                totalSpots: 20,
                totalRewardPool: 30,
                entryFee: 40,
                gameStatus: self.GameListed,
                gameDurationSeconds: 600,
                activePlayers: emptyMap(),
                createdAt: 0,
                startedAt: 0,
                completedAt: 0
            }
        );
    }

    get fun getOwner(): Address {
        return self.owner;
    }

    get fun Game(gameId: Int): map<Int as uint256, GameData> {
        let game: GameData?=self.gameList.get(gameId);
        let result: map<Int as uint256, GameData>=emptyMap();
        if(game==null){
            result.set(gameId,null);
        }else{
            result.set(gameId,game);
        }
        return result;
    }

    get fun TestDataFn(value: Int): Int? {
        return self.testData.get(value);
    }

    get fun TestMapFn(gameId: Int): GameData? {
        // let temp: GameData = self.testMap.get(gameId);
        // self.reply("TestMapFn".asComment());
        return null;
    }

    get fun TestStructureFn(key: Int): map<Int as uint256, CreateStruct> {
        //    dump(self.testStruct.get(key));
        //    let temp: CreateStruct?=self.testStruct.get(key);
        let result: map<Int as uint256, CreateStruct> = emptyMap();
        result.set(123, CreateStruct{value1: 2500, value2: key, value3: sender(), time: now()});
        return result;
    }

    get fun TestingMap(key: Int): map<Int as uint256, Test> {
        //    dump(self.testStruct.get(key));
        let temp: Test? = self.testingMap.get(key);
        let result: map<Int as uint256, Test> = null;
        if (temp == null) {
            result.set(key, null);
        } else {
            result.set(key, temp);
        }
        //    let result: map<Int as uint256, Test>;
        //    result.set(key,Test{address: sender(), time: now()});
        return result;
    }
}