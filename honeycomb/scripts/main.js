let abi = require('./abi.json');

let availableButton = document.getElementById('availableButton')
let registerButton = document.getElementById('registerButton')

availableButton.onclick = async () => {
    if (window.ethereum) {
        //window.web3 = new Web3(ethereum);
        try {
            await ethereum.enable();
            let contract = web3.eth.contract(abi, '0xdB824df2788FF1Cb086773a94708e690EA555b91');
            let contractInstance = contract.at('0xdB824df2788FF1Cb086773a94708e690EA555b91')

            let equipmentid = Math.floor(Math.random() * 101);
            let rentalId = Math.floor(Math.random() * 101);
            let equipmentIdGroup = document.getElementById('equipmentId').value
            let date = document.getElementById('rentalDate').value
            let windspeed = document.getElementById('windspeedSelect').value
            let location = document.getElementById('locationSelect').value
            let serviceFee = 10000

            contractInstance.equipmentAvailable(equipmentid, date.toString(), (e, f) => {
                if (f === false) {
                    alert('Date is still available! Continue to the last step to register the rental')
                }
            })
            document.getElementById('equipmentIdGroup').innerText = 'Equipment: ' + equipmentIdGroup
            document.getElementById('dateGroup').innerText = 'Date: ' + date
            document.getElementById('rentalIdGroup').innerText = 'RentalID: ' + rentalId
            document.getElementById('LocationGroup').innerText = 'Location: ' + location
            document.getElementById('WindspeedGroup').innerText = 'Min windspeed: ' + windspeed
            document.getElementById('serviceFeeGroup').innerText = 'Servicefee: ' + serviceFee
            let amount = 2111111111111
            let gasValue = 21000

            registerButton.onclick = function () {
                contractInstance.registerRentalContract(equipmentid, rentalId, date.toString(), windspeed, location.toString(), serviceFee, '0xdB824df2788FF1Cb086773a94708e690EA555b91',
                    {from: window.web3.currentProvider.selectedAddress, value: amount, gas: gasValue}, (err, call) => {
                        console.log(err, call)
                    })
            }


        } catch (error) {
            // User denied account access...
            //alert("We couldn't connect to MetaMask. Please check if you're logged in or MetaMask is installed!")
        }
    }
}




