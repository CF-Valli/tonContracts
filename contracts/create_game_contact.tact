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
  

message CreateGameList {
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
    data1: Int as uint256;
    data2: TestStructure;
}

message SetMap{
    gameId: Int as uint256;
}

contract CreateGameContact with Deployable, Ownable {
    
     owner: Address;
    
    const GameListed: Int = 0;
    const GameLive: Int = 1;
    const GameCompleted: Int = 2;
    const GameCancelled: Int = 3;

     
    gameList: map<Int as uint256, GameData>;
    testData: map<Int as uint256,Int as uint256>;
    testStruct: map<Int as uint256, TestStructure>;
    testMap: map<Int as uint256, GameData>;

    init() {
        self.owner = sender();
        // emit(OnGameContractDeployed{contractAddress: myAddress(),transaction_by: sender()}.toCell());
    }

    receive(msg: SetTestData) {
        self.testData.set(msg.value1, msg.value2);
    }

    receive(msg: SetStructureToMap) {
        self.testStruct.set(msg.data1,msg.data2);
    }

     receive(msg: CreateGameList) {
        self.requireOwner();
        let game = GameData {
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
        };
        self.gameList.set(msg.gameId, game);
        self.reply("Creating Game".asComment());
       
    }

    receive (msg: SetMap) {
         
        let game = GameData {
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
        };
        self.testMap.set(msg.gameId, game);
    }

     get fun getOwner(): Address {
        return self.owner;
    }

    get fun GameStatus(gameId: Int): GameData? {
        return self.gameList.get(gameId);
    }

    get fun TestDataFn(value: Int): Int? {
        return self.testData.get(value);
    }

    get fun TestMapFn(gameId: Int): GameData? {
        let temp: GameData? = self.testMap.get(gameId);
        self.reply("TestMapFn".asComment());
        return temp!!;
    }

    get fun TestStructureFn(key: Int): TestStructure? {
        return self.testStruct.get(key);
    }

}
