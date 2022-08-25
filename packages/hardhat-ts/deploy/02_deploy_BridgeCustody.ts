import { DeployFunction } from 'hardhat-deploy/types';
import { THardhatRuntimeEnvironmentExtended } from 'helpers/types/THardhatRuntimeEnvironmentExtended';

const func: DeployFunction = async (hre: THardhatRuntimeEnvironmentExtended) => {
  const { getNamedAccounts, deployments } = hre;
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();
  const yourNFT = await get('YourNFT');
  await deploy('BridgeCustody', {
    from: deployer,
    args: [yourNFT.address],
    log: true,
  });
};
export default func;
func.tags = ['all'];
