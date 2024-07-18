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

  

message CreateGameList {
    gameListData: map<Int as uint32, CreateGameRequest>;
}
message StartGameList {
    gameIds: map<Int as uint32, Int as uint32>;
}

message EndGameList {
    gameIds: map<Int as uint32, Int as uint32>;
}

message CancelGameList {
    gameIds: map<Int as uint32, Int as uint32>;
}

message JoinGame {
    gameId: Int as uint256
}

message OnGameContractDeployed {
    contractAddress: Address;
    transaction_by: Address;
}

message OnGameCreated {
    gameId: Int as uint256;
    createdAt: Int as uint256;
    transaction_by: Address;
}

message OnGameStarted {
    gameId: Int as uint256;
    startedAt: Int as uint256;
    transaction_by: Address;
}

message OnGameEnded {
    gameId: Int as uint256;
    completedAt: Int as uint256;
    transaction_by: Address;
}

message OnGameCancelled {
    gameId: Int as uint256;
    transaction_by: Address;
}

message OnUserJoinedGame {
  gameId: Int as uint256;
  userAddress: Address;
  joinedAt: Int as uint256;
  transaction_by: Address;
}

struct SuccessMessage{
    method: String;
    gameId: Int as uint256;
    status: String;
}
contract CfGameContract with Deployable, Ownable {
    owner: Address;
    
    const GameListed: Int = 0;
    const GameLive: Int = 1;
    const GameCompleted: Int = 2;
    const GameCancelled: Int = 3;

     
    gameList: map<Int as uint256, GameData>;

    init() {
        self.owner = sender();
        emit(OnGameContractDeployed{contractAddress: myAddress(),transaction_by: sender()}.toCell());
    }

    fun createGame(gameData: CreateGameRequest) {
        self.requireOwner();
        let createdAt: Int = now();
        self.gameList.set(gameData.gameId, 
        GameData {
        gameOwnerAddress: sender(),
        activePlayerCount: 0,
        totalSpots: gameData.totalSpots,
        totalRewardPool: gameData.totalRewardPool,
        entryFee: gameData.entryFee,
        gameStatus: self.GameListed,
        gameDurationSeconds: gameData.gameDurationSeconds,
        activePlayers: emptyMap(),
        createdAt: createdAt,
        startedAt: 0,
        completedAt: 0
        });
        self.reply("CreateGameSuccess".asComment());
       emit(OnGameCreated{gameId: gameData.gameId,createdAt:createdAt,transaction_by:sender()}.toCell());
    }


    fun StartGame(gameId: Int) {
        self.requireOwner();
        let gameData: GameData? = self.gameList.get(gameId);
        require(gameData != null,"Invalid Game Id");
        let tempData: GameData = gameData!!;
         require(tempData.gameStatus == self.GameListed, "Invalid Status");
        require(tempData.activePlayerCount > 1, "No Players Present In Game");
        let startedAt: Int = now();
        self.gameList.set(gameId, 
        GameData {
            gameOwnerAddress: tempData.gameOwnerAddress,
            activePlayerCount: tempData.activePlayerCount,
            totalSpots: tempData.totalSpots,
            totalRewardPool: tempData.totalRewardPool,
            entryFee: tempData.entryFee,
            gameStatus: self.GameLive,
            gameDurationSeconds: tempData.gameDurationSeconds,
            activePlayers: tempData.activePlayers,
            createdAt: tempData.createdAt,
            startedAt: startedAt,
            completedAt: tempData.completedAt
        });
        self.reply("GameStartSuccess".asComment());
        emit(OnGameStarted{gameId: gameId,startedAt:startedAt,transaction_by:tempData.gameOwnerAddress}.toCell());
        

    }

     fun EndGame(gameId: Int) {

       self.requireOwner();
        let gameData: GameData? = self.gameList.get(gameId);
        require(gameData != null,"Invalid Game Id");        
        let tempData: GameData = gameData!!;
        require(tempData.gameStatus == self.GameLive, "Invalid Status");
        require(now() - tempData.startedAt > tempData.gameDurationSeconds, "Game is still in progress");
        let completedAt: Int =now();
        self.gameList.set(gameId, 
        GameData {
            gameOwnerAddress: tempData.gameOwnerAddress,
            activePlayerCount: tempData.activePlayerCount,
            totalSpots: tempData.totalSpots,
            totalRewardPool: tempData.totalRewardPool,
            entryFee: tempData.entryFee,
            gameStatus: self.GameCompleted,
            gameDurationSeconds: tempData.gameDurationSeconds,
            activePlayers: tempData.activePlayers,
            createdAt: tempData.createdAt,
            startedAt: tempData.startedAt,
            completedAt: completedAt
        });
        self.reply("GameEndSuccess".asComment());
         emit(OnGameEnded{gameId: gameId,completedAt:completedAt,transaction_by:tempData.gameOwnerAddress}.toCell());

     }


     fun CancelGame(gameId: Int) {
        self.requireOwner();
        let gameData: GameData? = self.gameList.get(gameId);
        require(gameData != null,"Invalid Game Id");        
        let tempData: GameData = gameData!!;
        require(tempData.gameStatus == self.GameListed, "Invalid Status");
        self.gameList.set(gameId, 
        GameData {
            gameOwnerAddress: tempData.gameOwnerAddress,
            activePlayerCount: tempData.activePlayerCount,
            totalSpots: tempData.totalSpots,
            totalRewardPool: tempData.totalRewardPool,
            entryFee: tempData.entryFee,
            gameStatus: self.GameCancelled,
            gameDurationSeconds: tempData.gameDurationSeconds,
            activePlayers: tempData.activePlayers,
            createdAt: tempData.createdAt,
            startedAt: tempData.startedAt,
            completedAt: tempData.completedAt
        });
        self.reply("GameCancelSuccess".asComment());
        emit(OnGameCancelled{gameId: gameId,transaction_by:tempData.gameOwnerAddress}.toCell());
     }

    receive(msg: CreateGameList) {
        self.requireOwner();
        foreach (key, value in msg.gameListData) {
            let request: CreateGameRequest? = value;
            self.createGame(request!!);
        }
    }

    receive(msg: StartGameList) {
        self.requireOwner();
        foreach (key, value in msg.gameIds) {
            let request: Int? = value;
            self.StartGame(request!!);
        }

    }    

    receive (msg: EndGameList) {
        self.requireOwner();
        foreach(key, value in msg.gameIds){
            let tempGameId: Int? = value;
            self.EndGame(tempGameId!!);
        }
    }


    receive(msg: CancelGameList) {
        self.requireOwner();
        foreach(key, value in msg.gameIds){
            let tempGameId: Int?=value;
            self.CancelGame(tempGameId!!);
        }
       
    }

     receive(msg: JoinGame) {

        let gameData: GameData? = self.gameList.get(msg.gameId);
        require(gameData != null,"Invalid Game Id");
        let tempGameData = gameData!!;
        require(tempGameData.gameStatus == self.GameListed, "The game is not listed for joining");
        require(tempGameData.activePlayerCount < tempGameData.totalSpots, "The player count reached!");
        require(tempGameData.activePlayers.get(sender()) == null, "The player Already Joined!");
        let playerList: map<Address, Int as uint256> = tempGameData.activePlayers;
        playerList.set(sender(), now());

        self.gameList.set(msg.gameId, 
        GameData {
            gameOwnerAddress: tempGameData.gameOwnerAddress,
            activePlayerCount: tempGameData.activePlayerCount + 1,
            totalSpots: tempGameData.totalSpots,
            totalRewardPool: tempGameData.totalRewardPool,
            entryFee: tempGameData.entryFee,
            gameStatus: tempGameData.gameStatus,
            gameDurationSeconds: tempGameData.gameDurationSeconds,
            activePlayers: playerList,
            createdAt: tempGameData.createdAt,
            startedAt: tempGameData.startedAt,
            completedAt: tempGameData.completedAt
        });
        self.reply("UserJoinedGame".asComment());
        emit(OnUserJoinedGame{gameId: msg.gameId,userAddress: sender(),joinedAt: now(),transaction_by: sender()}.toCell());
             
    }

     get fun getOwner(): Address {
        return self.owner;
    }

    get fun ContractAddress(): Address {
        return myAddress();
    }

    get fun getGameStatus(gameId: Int): map<Int as uint256, GameData> {
        let game: GameData?=self.gameList.get(gameId);
        let result: map<Int as uint256, GameData>=emptyMap();
        if(game==null){
            result.set(gameId,null);
        }else{
            result.set(gameId,game);
        }
        return result;
    }

    get fun GamePlayer(gameId: Int, playerAddress: Address): map<Address, Int as uint256> {
        let game: GameData? =self.gameList.get(gameId);
        let result: map<Address, Int as uint256> = emptyMap();
        if(game != null) {
            let tempData = game!!;
        let playerList: map<Address, Int as uint256> = tempData.activePlayers;
        let playerData: Int? = playerList.get(playerAddress);
         result.set(playerAddress, playerData!!);
        }else {
         result.set(playerAddress, null);

        }
        return result;
    }
}
