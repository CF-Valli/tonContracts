import { toNano } from '@ton/core';
import { GameContract } from '../wrappers/GameContract';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const gameContract = provider.open(await GameContract.fromInit());

    await gameContract.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(gameContract.address);

    // run methods on `gameContract`
}
