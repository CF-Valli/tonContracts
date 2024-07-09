import { toNano } from '@ton/core';
import { CreateGameContact } from '../wrappers/CreateGameContact';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const createGameContact = provider.open(await CreateGameContact.fromInit());

    await createGameContact.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(createGameContact.address);

    // run methods on `createGameContact`
}
