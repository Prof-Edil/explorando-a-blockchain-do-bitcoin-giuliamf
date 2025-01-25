# Only one single output remains unspent from block 123,321. What address was it sent to?

#!/bin/bash

block_hash=$(bitcoin-cli getblockhash 123321)
readarray -t tx_list < <(bitcoin-cli getblock $block_hash | jq -r .tx[])

for transact_id in "${tx_list[@]}"
do  
    rawtx=$(bitcoin-cli getrawtransaction "$transact_id" true | jq -c .)   
    readarray -t outputs < <(echo "$rawtx" | jq -c .vout[])

    for output in "${outputs[@]}"
    do
        index=$(echo $output | jq -r .n)
        utxo=$(bitcoin-cli gettxout $transact_id $index)

        if [[ $utxo ]]
        then
            address=$(echo $utxo | jq -r .scriptPubKey.address)
            echo $address
            
        fi
        
    done
    
done
