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
    gameCount: Int as uint32;
}
message StartGameList {

    gameIds: map<Int as uint32, Int as uint32>;
    gameCount: Int as uint32;
}

message EndGameList {

    gameIds: map<Int as uint32, Int as uint32>;
    gameCount: Int as uint32;
}

message CancelGameList {

    gameIds: map<Int as uint32, Int as uint32>;
    gameCount: Int as uint32;
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
        let game = GameData {
        gameOwnerAddress: sender(),
        activePlayerCount: 0,
        totalSpots: gameData.totalSpots,
        totalRewardPool: gameData.totalRewardPool,
        entryFee: gameData.entryFee,
        gameStatus: self.GameListed,
        gameDurationSeconds: gameData.gameDurationSeconds,
        activePlayers: emptyMap(),
        createdAt: now(),
        startedAt: 0,
        completedAt: 0
        };
        self.gameList.set(gameData.gameId, game);
      //  emit(OnGameCreated{gameId: gameData.gameId,createdAt:game.createdAt,transaction_by:game.gameOwnerAddress}.toCell());
    }


    fun StartGame(gameId: Int) {
        self.requireOwner();
        let gameData: GameData? = self.gameList.get(gameId);
        if(gameData != null) {
        let tempData: GameData = gameData!!;
         require(tempData.gameStatus == self.GameListed, "Invalid Status");
        require(tempData.activePlayerCount > 1, "No Players Present In Game");
        let newGameData = GameData {
            gameOwnerAddress: tempData.gameOwnerAddress,
            activePlayerCount: tempData.activePlayerCount,
            totalSpots: tempData.totalSpots,
            totalRewardPool: tempData.totalRewardPool,
            entryFee: tempData.entryFee,
            gameStatus: self.GameLive,
            gameDurationSeconds: tempData.gameDurationSeconds,
            activePlayers: tempData.activePlayers,
            createdAt: tempData.createdAt,
            startedAt: now(),
            completedAt: tempData.completedAt
        };

        self.gameList.set(gameId, newGameData);
        emit(OnGameStarted{gameId: gameId,startedAt:newGameData.startedAt,transaction_by:newGameData.gameOwnerAddress}.toCell());
        }

    }

     fun EndGame(gameId: Int) {

         self.requireOwner();
        let gameData: GameData? = self.gameList.get(gameId);
        if(gameData != null) {
        let tempData: GameData = gameData!!;
        require(tempData.gameStatus == self.GameLive, "Invalid Status");
        require(now() - tempData.startedAt > tempData.gameDurationSeconds, "Game is still in progress");
         let newGameData = GameData {
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
            completedAt: now()
        };

        self.gameList.set(gameId, newGameData);
        emit(OnGameEnded{gameId: gameId,completedAt:newGameData.completedAt,transaction_by:newGameData.gameOwnerAddress}.toCell());
        }


     }


     fun CancelGame(gameId: Int) {

        self.requireOwner();
        let gameData: GameData? = self.gameList.get(gameId);
        if(gameData != null) {
            let tempData: GameData = gameData!!;
            require(tempData.gameStatus == self.GameListed, "Invalid Status");
            let newGameData = GameData {
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
        };

        self.gameList.set(gameId, newGameData);
        emit(OnGameCancelled{gameId: gameId,transaction_by:newGameData.gameOwnerAddress}.toCell());
        }


     }

    receive(msg: CreateGameList) {
        self.requireOwner();
        let i: Int = 1;
        repeat(msg.gameCount) {
            let tempGameData: CreateGameRequest? = msg.gameListData.get(i);
            if(tempGameData != null) {
                self.createGame(tempGameData!!);
            }
            i = i + 1;
        }
    }

    receive(msg: StartGameList) {
        self.requireOwner();
        let i: Int = 1;
        repeat(msg.gameCount) {
            let tempGameId: Int? = msg.gameIds.get(i);
            self.StartGame(tempGameId!!);
            i = i + 1;
        }

    }    

    receive (msg: EndGameList) {
        self.requireOwner();
        let i: Int = 1;
        repeat(msg.gameCount) {
            let tempGameId: Int? = msg.gameIds.get(i);
            self.StartGame(tempGameId!!);
            i = i + 1;
        }
    }


    receive(msg: CancelGameList) {
        self.requireOwner();
        let i: Int = 1;
        repeat(msg.gameCount) {
            let tempGameId: Int? = msg.gameIds.get(i);
            self.CancelGame(tempGameId!!);
            i = i + 1;
        }
    }

     receive(msg: JoinGame) {

        let gameData: GameData? = self.gameList.get(msg.gameId);
        if(gameData != null) {
            let tempGameData = gameData!!;
            require(tempGameData.gameStatus == self.GameListed, "The game is not listed for joining");
            require(tempGameData.activePlayerCount < tempGameData.totalSpots, "The player count reached!");
            require(tempGameData.activePlayers.get(sender()) == null, "The player Already Joined!");
            let playerList: map<Address, Int as uint256> = tempGameData.activePlayers;
            playerList.set(sender(), now());

            let newGameData = GameData {
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
            };

            self.gameList.set(msg.gameId, newGameData);
            self.reply("Joining Game .....".asComment());
            emit(OnUserJoinedGame{gameId: msg.gameId,userAddress: sender(),joinedAt: now(),transaction_by: sender()}.toCell());
        }       
    }

     get fun getOwner(): Address {
        return self.owner;
    }

    get fun getGameStatus(gameId: Int): GameData? {
        return self.gameList.get(gameId);
    }
}
