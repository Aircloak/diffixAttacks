# diffixAttacks

This repo contains an example attack on the Diffix anonymization system implemented by Aircloak. This code can be used as the basis for writing ones own attack.

## To Install

This directory requires the public repository `Aircloak/diffixAttackModules`. diffixAttackModules and diffixAttacks should share the same parent directory. If they do not, then modify the `use lib 'path';` lines in the `file.pl` files.

## To Configure

Copy `Aircloak/diffixAttackModules/diffixAttackConfig/genConfig-example.pm` to the file `genConfig.pm` in the same directory. Modify `getConfig.pm` to contain the API token needed for authentication. The token can be requested from your account on attack.aircloak.com.

Copy `Aircloak/diffixAttackModules/diffixAttackConfig/dbConfig-example.pm` to the file `dbConfig.pm` in the same directory. Configure the information needed to connect to your database installation.

## The Attacks

Each attack is in a subdirectory in the `attacks` directory. Each subdirectory has its own `README.md` describing the attack.

## Note Well

This software is distributed "as is". It is meant to serve as an example of how to run an attack, and is not well-documented or for instance designed to be easy to install. If you have questions you may wish to join the discussion group at forum.aircloak.com.
