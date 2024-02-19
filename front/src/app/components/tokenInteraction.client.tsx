'use client';
import React, { useState } from 'react';
import { ethers } from 'ethers';
import erc20ABI from './abi/ERC20.json';

declare global {
  interface Window {
    ethereum: any
  }
}

export default function TokenInteraction() {
  
  const priceFeed = "0xEFE76478C42fa1AC7923091c652e556e51C3dF5A";
  const tokens = [
    { name: 'DAI', address: '0x7742F29160F9FF3BCae128d2CC8416168868A5d2' },
    { name: 'WETH', address: '0xCF017B4E3C31609E1cED4ceB6d8f923f51aaa791' },
    { name: 'WBTC', address: '0xA4053edA308139C90e15629275CB94165f98BE25' },
  ];

  const [balance, setBalance] = useState('');
  const [tokenAddress, setTokenAddress] = useState('');
  const [userAddress, setUserAddress] = useState('');

  const provider = new ethers.BrowserProvider(window.ethereum);
  
  async function changeNetwork() {
    try {
      await window.ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [{
          chainId: '0xaa36a7',
          chainName: 'Sepolia',
          nativeCurrency: {
            name: 'ETHEREUM',
            symbol: 'ETH',
            decimals: 18, 
          },
          rpcUrls: ['https://ethereum-sepolia.publicnode.com'], 
          blockExplorerUrls: null,  
        }],
      });
    } catch (addError) {
      // 네트워크 추가에 실패한 경우 오류 처리
      console.error('Failed to add the network:', addError);
    }
  }

  const checkBalance = async () => {
    if (!tokenAddress || !userAddress) return;
    const tokenABI = erc20ABI.abi;
    const tokenContract = new ethers.Contract(tokenAddress, tokenABI, provider);
    const balance = await tokenContract.balanceOf(userAddress);
    setBalance(ethers.formatEther(balance));
  };
  
  const faucet = async () => {
    const signer = await provider.getSigner();
    if (!tokenAddress || !userAddress) return;
    const tokenABI = erc20ABI.abi;
    const tokenContract = new ethers.Contract(tokenAddress, tokenABI, signer);
    await tokenContract.mint(userAddress, ethers.parseEther("10000000.0"));
  };

  return (
    <div>
      <button onClick={changeNetwork}>change network</button>
      <select value={tokenAddress} onChange={(e) => setTokenAddress(e.target.value)}>
        <option value="">토큰을 선택해주세요</option>
        {tokens.map((token) => (
          <option key={token.address} value={token.address}>
            {token.name}
          </option>
        ))}
      </select>
      <input type="text" value={userAddress} onChange={(e) => setUserAddress(e.target.value)} placeholder="사용자 주소" />
      <button onClick={checkBalance}>잔액 확인</button>
      <div>잔액: {balance}</div>
      <button onClick={faucet}>token faucet</button>
    </div>
  );
}