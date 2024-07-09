import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/create_game_contact.tact',
    options: {
        debug: true,
    },
};
