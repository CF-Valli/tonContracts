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

  

message CreateGame {
    game: CreateGameRequest
}

message JoinGame {
    gameId: Int as uint256
}

message StartGame {
    gameId: Int as uint256
}

message EndGame {
    gameId: Int as uint256
}

message CancelGame {
    gameId: Int as uint256
}


message OnGameContractDeployed {
     transaction_by: Address;
}

message OnGameCreated {
    gameId: Int as uint256;
    createdAt: Int as uint256;
    transaction_by: Address;
}

message OnUserJoinedGame {
  gameId: Int as uint256;
  userAddress: Address;
  joinedAt: Int as uint256;
  transaction_by: Address;
}

message OnGameStarted {
    gameId: Int as uint256;
    startedAt: Int as uint256;
    transaction_by: Address;
}

message OnGameCompleted {
    gameId: Int as uint256;
    completedAt: Int as uint256;
    transaction_by: Address;
}


message OnGameCanceled {
    gameId: Int as uint256;
    transaction_by: Address;
}

contract GameContract with Deployable, Ownable {
    owner: Address;
    
    const GameListed: Int = 0;
    const GameLive: Int = 1;
    const GameCompleted: Int = 2;
    const GameCancelled: Int = 3;

     
    gameList: map<Int as uint256, GameData>;

    init() {
        self.owner = sender();
       // emit(OnGameContractDeployed{sender()}.toCell());
    }
     
    receive(msg: CreateGame) {
        let game = GameData {
        gameOwnerAddress: sender(),
        activePlayerCount: 0,
        totalSpots: msg.game.totalSpots,
        totalRewardPool: msg.game.totalRewardPool,
        entryFee: msg.game.entryFee,
        gameStatus: self.GameListed,
        gameDurationSeconds: msg.game.gameDurationSeconds,
        activePlayers: emptyMap(),
        createdAt: now(),
        startedAt: 0,
        completedAt: 0
        };
        self.gameList.set(msg.game.gameId, game);

       emit(OnGameCreated{gameId: msg.game.gameId,createdAt: game.createdAt,transaction_by:game.gameOwnerAddress}.toCell());
    }

    receive(msg: JoinGame) {

        let gameData: GameData? = self.gameList.get(msg.gameId);
               
        require(gameData.gameStatus == GameListed, "The game is not listed for joining");
        require(gameData.activePlayerCount < gameData.totalSpots, "The player count reached!");
        require(gameData.activePlayers.get(sender()), "The player Already Joined!");
        let newGameData = GameData {
            gameOwnerAddress: gameData.gameOwnerAddress,
            activePlayerCount: gameData.activePlayerCount + 1,
            totalSpots: gameData.totalSpots,
            totalRewardPool: gameData.totalRewardPool,
            entryFee: gameData.entryFee,
            gameStatus: gameData.gameStatus,
            gameDurationSeconds: gameData.gameDurationSeconds,
            activePlayers: gameData.activePlayers.set(sender(), now()),
            createdAt: gameData.createdAt,
            startedAt: gameData.startedAt,
            completedAt: gameData.completedAt
        };

        self.gameList.set(msg.gameId, newGameData);
       // emit(OnUserJoinedGame{msg.gameId,sender(),newGameData.activePlayers.get(sender()),sender()}.toCell());
    }


    receive(msg: StartGame) {

        let gameData: GameData = self.gameList.get(msg.gameId);
               
        require(gameData.gameStatus == GameListed, "Invalid Status");
        require(gameData.activePlayerCount > 1, "No Players Present In Game");
        

        let newGameData = GameData {
            gameOwnerAddress: gameData.gameOwnerAddress,
            activePlayerCount: gameData.activePlayerCount,
            totalSpots: gameData.totalSpots,
            totalRewardPool: gameData.totalRewardPool,
            entryFee: gameData.entryFee,
            gameStatus: GameLive,
            gameDurationSeconds: gameData.gameDurationSeconds,
            activePlayers: gameData.activePlayers,
            createdAt: gameData.createdAt,
            startedAt: now(),
            completedAt: gameData.completedAt
        };

        self.gameList.set(msg.gameId, newGameData);
      //  emit(OnGameStarted{msg.gameId,newGameData.startedAt,sender()}.toCell());
    }


    receive(msg: EndGame) {

        let gameData: GameData = self.gameList.get(msg.gameId);
               
        require(gameData.gameStatus == GameLive, "Invalid Status");
        require(now() - gameData.startedAt > gameData.gameDurationSeconds, "Game is still in progress");
        

        let newGameData = GameData {
            gameOwnerAddress: gameData.gameOwnerAddress,
            activePlayerCount: gameData.activePlayerCount,
            totalSpots: gameData.totalSpots,
            totalRewardPool: gameData.totalRewardPool,
            entryFee: gameData.entryFee,
            gameStatus: GameLive,
            gameDurationSeconds: gameData.gameDurationSeconds,
            activePlayers: gameData.activePlayers,
            createdAt: gameData.createdAt,
            startedAt: gameData.startedAt,
            completedAt: now()
        };

        self.gameList.set(msg.gameId, newGameData);
      //  emit(OnGameCompleted{msg.gameId,newGameData.completedAt,sender()}.toCell());
    }

    receive(msg: CancelGame) {

        let gameData: GameData = self.gameList.get(msg.gameId);
               
        require(gameData.gameStatus == GameListed, "Invalid Status");
             

        let newGameData = GameData {
            gameOwnerAddress: gameData.gameOwnerAddress,
            activePlayerCount: gameData.activePlayerCount,
            totalSpots: gameData.totalSpots,
            totalRewardPool: gameData.totalRewardPool,
            entryFee: gameData.entryFee,
            gameStatus: GameCancelled,
            gameDurationSeconds: gameData.gameDurationSeconds,
            activePlayers: gameData.activePlayers,
            createdAt: gameData.createdAt,
            startedAt: gameData.startedAt,
            completedAt: gameData.completedAt
        };

        self.gameList.set(msg.gameId, newGameData);
       // emit(OnGameCanceled{msg.gameId,sender()}.toCell())
    }

    get fun getOwner(): Address {
        return self.owner;
    }

    get fun getGameStatus(gameId: Int): GameData? {
        return self.gameList.get(gameId);
    }

    get fun getGamePlayer(gameId: Int): Int? {
        let game = self.gameList.get(gameId);
        return game.activePlayers.get(sender());
    } 
    
}