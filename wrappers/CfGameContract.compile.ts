import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/cf_game_contract.tact',
    options: {
        debug: true,
    },
};
