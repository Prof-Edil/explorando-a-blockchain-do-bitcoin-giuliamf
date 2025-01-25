# Only one single output remains unspent from block 123,321. What address was it sent to?

#!/bin/bash

block_hash = $(bitcoin-cli getblockhash 123321)
readarray -t transact_list < <(bitcoin-cli getblock "$block_hash" | jq -r '.tx[]')

for transact_id in "${transact_list[@]}"
do
        raw_transact=$(bitcoin-cli getrawtransaction "$transact_id" true | jq -c .)
        readarray -t output_list < <(echo "$raw_transact" | jq -c '.vout[]')

        for output_entry in "${output_list[@]}"
        do
                output_idx=$(echo "$output_entry" | jq -r '.n')
                utxo=$(bitcoin-cli gettxout "$transact_id" "$output_idx")

                if [[ $utxo ]] 
                then
                        output_address=$(echo "$utxo" | jq -r '.scriptPubKey.address')
                        echo "$output_address"
                fi
        done
done
