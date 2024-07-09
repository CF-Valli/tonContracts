import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { CfGameContract } from '../wrappers/CfGameContract';
import '@ton/test-utils';

describe('CfGameContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let cfGameContract: SandboxContract<CfGameContract>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        cfGameContract = blockchain.openContract(await CfGameContract.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await cfGameContract.send(
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
            to: cfGameContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and cfGameContract are ready to use
    });
});
