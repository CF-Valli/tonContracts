import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { CreateGameContact } from '../wrappers/CreateGameContact';
import '@ton/test-utils';

describe('CreateGameContact', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let createGameContact: SandboxContract<CreateGameContact>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        createGameContact = blockchain.openContract(await CreateGameContact.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await createGameContact.send(
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
            to: createGameContact.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and createGameContact are ready to use
    });
});
