# How many new outputs were created by block 123,456?

#!/bin/bash
block_hash=$(bitcoin-cli getblockhash 123456)

block=$(bitcoin-cli getblock $block_hash true)
transactions=$(echo $block | jq -r '.tx[]')

total_outputs=0

for txid in $transactions; do
	raw_tx=$(bitcoin-cli getrawtransaction $txid true)
	outputs=$(echo $raw_tx | jq '.vout | length')
	total_outputs=$((total_outputs + outputs))
done

echo $total_outputs
