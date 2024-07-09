import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { GameContract } from '../wrappers/GameContract';
import '@ton/test-utils';

describe('GameContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let gameContract: SandboxContract<GameContract>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        gameContract = blockchain.openContract(await GameContract.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await gameContract.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: gameContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and gameContract are ready to use
    });
});
