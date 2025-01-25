# Which tx in block 257,343 spends the coinbase output of block 256,128?

#!/bin/bash
coinbase_tx=$(bitcoin-core.cli getblock $(bitcoin-core.cli getblockhash 256128) true | jq -r '.tx[0]')

block=$(bitcoin-core.cli getblock $(bitcoin-core.cli getblockhash 257343) true)

spending_tx=$(echo "$block" | jq -r '.tx[]' | while read txid; do
  tx=$(bitcoin-core.cli getrawtransaction $txid true)
  if echo "$tx" | jq -e ".vin[] | select(.txid == \"$coinbase_tx\")" > /dev/null; then
    echo $txid
    break
  fi
done)

echo $spending_tx
