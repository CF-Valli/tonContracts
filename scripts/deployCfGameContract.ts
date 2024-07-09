import { toNano } from '@ton/core';
import { CfGameContract } from '../wrappers/CfGameContract';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const cfGameContract = provider.open(await CfGameContract.fromInit());

    await cfGameContract.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(cfGameContract.address);

    // run methods on `cfGameContract`
}
