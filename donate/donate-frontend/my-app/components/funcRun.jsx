import { useWeb3Contract, useMoralis } from "react-moralis";
import { ABI, ContractAddressess } from "@/constants";
import { useEffect, useState } from "react";
import { ethers } from "ethers";
import { useNotification } from "web3uikit";
const FuncRun = () => {
  const [tokenInputValue, setTokenInputValue] = useState(0);
  const [notify, setNotify] = useState(false);

  //UI INFORMATIONS
  const [donatorList, setDonatorList] = useState([]);
  const [contractBalance, setContractBalance] = useState("0");
  const { chainId: chainIdHex, isWeb3Enabled, account } = useMoralis();
  const chainId = parseInt(chainIdHex);

  console.log(`Account Connected: ${account}`);
  const donateContractAddress =
    chainId in ContractAddressess ? ContractAddressess[chainId][0] : null;

  const { runContractFunction: payFee } = useWeb3Contract({
    functionName: "payFee",
    abi: ABI,
    msgValue: tokenInputValue,
    contractAddress: donateContractAddress,
    params: {},
  });

  const { runContractFunction: getDonatorList } = useWeb3Contract({
    functionName: "getDonatorList",
    abi: ABI,
    contractAddress: donateContractAddress,
    params: {},
  });

  const { runContractFunction: getBalance } = useWeb3Contract({
    functionName: "getBalance",
    abi: ABI,
    contractAddress: donateContractAddress,
    params: {},
  });

  const { runContractFunction: withdrawFunds } = useWeb3Contract({
    functionName: "withdrawFunds",
    abi: ABI,
    contractAddress: donateContractAddress,
    params: {},
  });

  const updateUI = async () => {
    const listOfDonatorResponse = await getDonatorList();
    const getBalanceTx = (await getBalance()).toString();
    setContractBalance(getBalanceTx);
    setDonatorList(listOfDonatorResponse);
  };

  const dispatch = useNotification();
  const handlePayFee = async () => {
    if (tokenInputValue == 0) {
      return setNotify(true);
    }
    await payFee({
      onSuccess: handleSuccess,
      onError: (e) => {
        if (e.message.includes("User denied transaction")) {
          handleFailedNotification("Transaction Rejected");
        } else {
          handleFailedNotification("Transaction Failed");
        }
      },
    });
  };

  const handleWithdraw = async () => {
    await withdrawFunds({
      onSuccess: handleWithdrawSuccess,
      onError: (e) => {
        if (e.message.includes("")) {
          handleFailedNotification("Withdrawal Denied");
        }
      },
    });
  };

  const handleSuccess = async (tx) => {
    await tx.wait();
    await handleSuccessNotification("Transaction Successful");
    setTokenInputValue("");
    updateUI();
  };

  const handleWithdrawSuccess = async (tx) => {
    await tx.wait();
    await handleSuccessNotification("Withdrawal Successful");
    updateUI();
  };

  const handleSuccessNotification = async (successMessage) => {
    dispatch({
      type: "info",
      message: successMessage,
      position: "topR",
    });
  };

  const handleFailedNotification = async (errorMessage) => {
    dispatch({
      type: "info",
      message: errorMessage,
      position: "topR",
    });
  };

  const listOfDonators =
    donatorList && donatorList.map((eachDonator) => <p>{eachDonator}</p>);

  useEffect(() => {
    if (isWeb3Enabled) {
      updateUI();
    }
  }, [isWeb3Enabled]);

  return (
    <div className="content">
      <h1>
        Balance of Contract:
        {ethers.utils.formatUnits(contractBalance, "ether")}eth
      </h1>
      <div className="inputValue">
        {notify && <p>Value Must Be Greater Than Zero</p>}
        <input
          type="number"
          value={tokenInputValue}
          required
          onChange={(e) => setTokenInputValue(e.target.value)}
        />
        <button onClick={handlePayFee}>Donate</button>
        {donateContractAddress ? (
          <div className="withdraw">
            <button onClick={handleWithdraw}>Withdraw</button>
          </div>
        ) : null}

        <hr />
        <h1>Donator</h1>
        <div className="list_of_donators">{listOfDonators}</div>
      </div>
    </div>
  );
};

export default FuncRun;