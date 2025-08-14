include .env

deploy_hahacoin:
	@echo "Deploying HaHaCoin contract..."
	forge create src/HaHaCoin.sol:HaHaCoin --private-key ${OWNER_PRIVATE_KEY} --broadcast --constructor-args ${OWNER_ADDRESS}

deploy_faucet:
	@echo "Deploying HHCFaucet contract..."
	forge create src/HHCFaucet.sol:HHCFaucet --private-key ${OWNER_PRIVATE_KEY} --broadcast --constructor-args ${HHC_CONTRACT} ${DRIP_INTERVAL} ${DRIP_LIMIT} ${OWNER_ADDRESS}

mint:
	@echo "Minting tokens..."
	cast send ${HHC_CONTRACT} "mint(uint256)" ${MINT_AMOUNT} --private-key ${OWNER_PRIVATE_KEY}

balance_of_owner:
	@echo "Getting balance of the owner..."
	cast call ${HHC_CONTRACT} "balanceOf(address)" ${OWNER_ADDRESS}

approve_faucet:
	@echo "Approving faucet contract to spend tokens..."
	cast send ${HHC_CONTRACT} "approve(address,uint256)" ${FAUCET_CONTRACT} ${DEPOSIT_AMOUNT} --private-key ${OWNER_PRIVATE_KEY}

drip:
	@echo "Dripping tokens from faucet..."
	cast send ${FAUCET_CONTRACT} "drip(uint256)" ${DRIP_AMOUNT} --private-key ${USER_PRIVATE_KEY}

deposit:
	@echo "Depositing tokens to faucet..."
	cast send ${FAUCET_CONTRACT} "deposit(uint256)" ${DEPOSIT_AMOUNT} --private-key ${OWNER_PRIVATE_KEY}

balance_of_faucet:
	@echo "Getting balance of the faucet contract..."
	cast call ${HHC_CONTRACT} "balanceOf(address)" ${FAUCET_CONTRACT}

balance_of_user:
	@echo "Getting balance of user..."
	cast call ${HHC_CONTRACT} "balanceOf(address)" ${USER_ADDRESS}