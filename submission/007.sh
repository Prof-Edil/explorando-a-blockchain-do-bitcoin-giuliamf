# Only one single output remains unspent from block 123,321. What address was it sent to?

#!/bin/bash
set -e

block_hash=$(bitcoin-cli getblockhash 123321)
block=$(bitcoin-cli getblock "$block_hash" true)
utxo_address=""

for txid in $(echo "$block" | jq -r '.tx[]'); do
  raw_tx=$(bitcoin-cli getrawtransaction "$txid" true)
  
  for vout_index in $(echo "$raw_tx" | jq -r '.vout[].n'); do
    txout=$(bitcoin-cli gettxout "$txid" "$vout_index")
    
    if [ -n "$txout" ]; then
      utxo_address=$(echo "$txout" | jq -r '.scriptPubKey.addresses[0]')
      
      if [ "$utxo_address" == "null" ] || [ -z "$utxo_address" ]; then
        script_hex=$(echo "$txout" | jq -r '.scriptPubKey.hex')
        utxo_address=$(bitcoin-cli decodescript "$script_hex" | jq -r '.p2sh')
      fi
      
      if [ -n "$utxo_address" ] && [ "$utxo_address" != "null" ]; then
        echo "$utxo_address"
        exit 0
      fi
    fi
  done
done

exit 1
