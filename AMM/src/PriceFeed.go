// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package main

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// PriceFeedMetaData contains all meta data concerning the PriceFeed contract.
var PriceFeedMetaData = &bind.MetaData{
	ABI: "[{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"address\",\"name\":\"asset\",\"type\":\"address\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"price\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"timestamp\",\"type\":\"uint256\"}],\"name\":\"AssetPriceUpdated\",\"type\":\"event\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"price\",\"type\":\"uint256\"},{\"indexed\":false,\"internalType\":\"uint256\",\"name\":\"timestamp\",\"type\":\"uint256\"}],\"name\":\"EthPriceUpdated\",\"type\":\"event\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"asset\",\"type\":\"address\"}],\"name\":\"getAssetPrice\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"healthCheck\",\"outputs\":[{\"internalType\":\"bool\",\"name\":\"\",\"type\":\"bool\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[],\"name\":\"lastUpdate\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"address\",\"name\":\"asset\",\"type\":\"address\"},{\"internalType\":\"uint256\",\"name\":\"price\",\"type\":\"uint256\"}],\"name\":\"setAssetPrice\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
}

// PriceFeedABI is the input ABI used to generate the binding from.
// Deprecated: Use PriceFeedMetaData.ABI instead.
var PriceFeedABI = PriceFeedMetaData.ABI

// PriceFeed is an auto generated Go binding around an Ethereum contract.
type PriceFeed struct {
	PriceFeedCaller     // Read-only binding to the contract
	PriceFeedTransactor // Write-only binding to the contract
	PriceFeedFilterer   // Log filterer for contract events
}

// PriceFeedCaller is an auto generated read-only Go binding around an Ethereum contract.
type PriceFeedCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// PriceFeedTransactor is an auto generated write-only Go binding around an Ethereum contract.
type PriceFeedTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// PriceFeedFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type PriceFeedFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// PriceFeedSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type PriceFeedSession struct {
	Contract     *PriceFeed        // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// PriceFeedCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type PriceFeedCallerSession struct {
	Contract *PriceFeedCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts    // Call options to use throughout this session
}

// PriceFeedTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type PriceFeedTransactorSession struct {
	Contract     *PriceFeedTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts    // Transaction auth options to use throughout this session
}

// PriceFeedRaw is an auto generated low-level Go binding around an Ethereum contract.
type PriceFeedRaw struct {
	Contract *PriceFeed // Generic contract binding to access the raw methods on
}

// PriceFeedCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type PriceFeedCallerRaw struct {
	Contract *PriceFeedCaller // Generic read-only contract binding to access the raw methods on
}

// PriceFeedTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type PriceFeedTransactorRaw struct {
	Contract *PriceFeedTransactor // Generic write-only contract binding to access the raw methods on
}

// NewPriceFeed creates a new instance of PriceFeed, bound to a specific deployed contract.
func NewPriceFeed(address common.Address, backend bind.ContractBackend) (*PriceFeed, error) {
	contract, err := bindPriceFeed(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &PriceFeed{PriceFeedCaller: PriceFeedCaller{contract: contract}, PriceFeedTransactor: PriceFeedTransactor{contract: contract}, PriceFeedFilterer: PriceFeedFilterer{contract: contract}}, nil
}

// NewPriceFeedCaller creates a new read-only instance of PriceFeed, bound to a specific deployed contract.
func NewPriceFeedCaller(address common.Address, caller bind.ContractCaller) (*PriceFeedCaller, error) {
	contract, err := bindPriceFeed(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &PriceFeedCaller{contract: contract}, nil
}

// NewPriceFeedTransactor creates a new write-only instance of PriceFeed, bound to a specific deployed contract.
func NewPriceFeedTransactor(address common.Address, transactor bind.ContractTransactor) (*PriceFeedTransactor, error) {
	contract, err := bindPriceFeed(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &PriceFeedTransactor{contract: contract}, nil
}

// NewPriceFeedFilterer creates a new log filterer instance of PriceFeed, bound to a specific deployed contract.
func NewPriceFeedFilterer(address common.Address, filterer bind.ContractFilterer) (*PriceFeedFilterer, error) {
	contract, err := bindPriceFeed(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &PriceFeedFilterer{contract: contract}, nil
}

// bindPriceFeed binds a generic wrapper to an already deployed contract.
func bindPriceFeed(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := PriceFeedMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_PriceFeed *PriceFeedRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _PriceFeed.Contract.PriceFeedCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_PriceFeed *PriceFeedRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _PriceFeed.Contract.PriceFeedTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_PriceFeed *PriceFeedRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _PriceFeed.Contract.PriceFeedTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_PriceFeed *PriceFeedCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _PriceFeed.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_PriceFeed *PriceFeedTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _PriceFeed.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_PriceFeed *PriceFeedTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _PriceFeed.Contract.contract.Transact(opts, method, params...)
}

// GetAssetPrice is a free data retrieval call binding the contract method 0xb3596f07.
//
// Solidity: function getAssetPrice(address asset) view returns(uint256)
func (_PriceFeed *PriceFeedCaller) GetAssetPrice(opts *bind.CallOpts, asset common.Address) (*big.Int, error) {
	var out []interface{}
	err := _PriceFeed.contract.Call(opts, &out, "getAssetPrice", asset)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// GetAssetPrice is a free data retrieval call binding the contract method 0xb3596f07.
//
// Solidity: function getAssetPrice(address asset) view returns(uint256)
func (_PriceFeed *PriceFeedSession) GetAssetPrice(asset common.Address) (*big.Int, error) {
	return _PriceFeed.Contract.GetAssetPrice(&_PriceFeed.CallOpts, asset)
}

// GetAssetPrice is a free data retrieval call binding the contract method 0xb3596f07.
//
// Solidity: function getAssetPrice(address asset) view returns(uint256)
func (_PriceFeed *PriceFeedCallerSession) GetAssetPrice(asset common.Address) (*big.Int, error) {
	return _PriceFeed.Contract.GetAssetPrice(&_PriceFeed.CallOpts, asset)
}

// HealthCheck is a free data retrieval call binding the contract method 0xb252720b.
//
// Solidity: function healthCheck() view returns(bool)
func (_PriceFeed *PriceFeedCaller) HealthCheck(opts *bind.CallOpts) (bool, error) {
	var out []interface{}
	err := _PriceFeed.contract.Call(opts, &out, "healthCheck")

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// HealthCheck is a free data retrieval call binding the contract method 0xb252720b.
//
// Solidity: function healthCheck() view returns(bool)
func (_PriceFeed *PriceFeedSession) HealthCheck() (bool, error) {
	return _PriceFeed.Contract.HealthCheck(&_PriceFeed.CallOpts)
}

// HealthCheck is a free data retrieval call binding the contract method 0xb252720b.
//
// Solidity: function healthCheck() view returns(bool)
func (_PriceFeed *PriceFeedCallerSession) HealthCheck() (bool, error) {
	return _PriceFeed.Contract.HealthCheck(&_PriceFeed.CallOpts)
}

// LastUpdate is a free data retrieval call binding the contract method 0xc0463711.
//
// Solidity: function lastUpdate() view returns(uint256)
func (_PriceFeed *PriceFeedCaller) LastUpdate(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _PriceFeed.contract.Call(opts, &out, "lastUpdate")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// LastUpdate is a free data retrieval call binding the contract method 0xc0463711.
//
// Solidity: function lastUpdate() view returns(uint256)
func (_PriceFeed *PriceFeedSession) LastUpdate() (*big.Int, error) {
	return _PriceFeed.Contract.LastUpdate(&_PriceFeed.CallOpts)
}

// LastUpdate is a free data retrieval call binding the contract method 0xc0463711.
//
// Solidity: function lastUpdate() view returns(uint256)
func (_PriceFeed *PriceFeedCallerSession) LastUpdate() (*big.Int, error) {
	return _PriceFeed.Contract.LastUpdate(&_PriceFeed.CallOpts)
}

// SetAssetPrice is a paid mutator transaction binding the contract method 0x51323f72.
//
// Solidity: function setAssetPrice(address asset, uint256 price) returns()
func (_PriceFeed *PriceFeedTransactor) SetAssetPrice(opts *bind.TransactOpts, asset common.Address, price *big.Int) (*types.Transaction, error) {
	return _PriceFeed.contract.Transact(opts, "setAssetPrice", asset, price)
}

// SetAssetPrice is a paid mutator transaction binding the contract method 0x51323f72.
//
// Solidity: function setAssetPrice(address asset, uint256 price) returns()
func (_PriceFeed *PriceFeedSession) SetAssetPrice(asset common.Address, price *big.Int) (*types.Transaction, error) {
	return _PriceFeed.Contract.SetAssetPrice(&_PriceFeed.TransactOpts, asset, price)
}

// SetAssetPrice is a paid mutator transaction binding the contract method 0x51323f72.
//
// Solidity: function setAssetPrice(address asset, uint256 price) returns()
func (_PriceFeed *PriceFeedTransactorSession) SetAssetPrice(asset common.Address, price *big.Int) (*types.Transaction, error) {
	return _PriceFeed.Contract.SetAssetPrice(&_PriceFeed.TransactOpts, asset, price)
}

// PriceFeedAssetPriceUpdatedIterator is returned from FilterAssetPriceUpdated and is used to iterate over the raw logs and unpacked data for AssetPriceUpdated events raised by the PriceFeed contract.
type PriceFeedAssetPriceUpdatedIterator struct {
	Event *PriceFeedAssetPriceUpdated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *PriceFeedAssetPriceUpdatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(PriceFeedAssetPriceUpdated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(PriceFeedAssetPriceUpdated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *PriceFeedAssetPriceUpdatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *PriceFeedAssetPriceUpdatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// PriceFeedAssetPriceUpdated represents a AssetPriceUpdated event raised by the PriceFeed contract.
type PriceFeedAssetPriceUpdated struct {
	Asset     common.Address
	Price     *big.Int
	Timestamp *big.Int
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterAssetPriceUpdated is a free log retrieval operation binding the contract event 0xce6e0b57367bae95ca7198e1172f653ea64a645c16ab586b4cefa9237bfc2d92.
//
// Solidity: event AssetPriceUpdated(address asset, uint256 price, uint256 timestamp)
func (_PriceFeed *PriceFeedFilterer) FilterAssetPriceUpdated(opts *bind.FilterOpts) (*PriceFeedAssetPriceUpdatedIterator, error) {

	logs, sub, err := _PriceFeed.contract.FilterLogs(opts, "AssetPriceUpdated")
	if err != nil {
		return nil, err
	}
	return &PriceFeedAssetPriceUpdatedIterator{contract: _PriceFeed.contract, event: "AssetPriceUpdated", logs: logs, sub: sub}, nil
}

// WatchAssetPriceUpdated is a free log subscription operation binding the contract event 0xce6e0b57367bae95ca7198e1172f653ea64a645c16ab586b4cefa9237bfc2d92.
//
// Solidity: event AssetPriceUpdated(address asset, uint256 price, uint256 timestamp)
func (_PriceFeed *PriceFeedFilterer) WatchAssetPriceUpdated(opts *bind.WatchOpts, sink chan<- *PriceFeedAssetPriceUpdated) (event.Subscription, error) {

	logs, sub, err := _PriceFeed.contract.WatchLogs(opts, "AssetPriceUpdated")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(PriceFeedAssetPriceUpdated)
				if err := _PriceFeed.contract.UnpackLog(event, "AssetPriceUpdated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseAssetPriceUpdated is a log parse operation binding the contract event 0xce6e0b57367bae95ca7198e1172f653ea64a645c16ab586b4cefa9237bfc2d92.
//
// Solidity: event AssetPriceUpdated(address asset, uint256 price, uint256 timestamp)
func (_PriceFeed *PriceFeedFilterer) ParseAssetPriceUpdated(log types.Log) (*PriceFeedAssetPriceUpdated, error) {
	event := new(PriceFeedAssetPriceUpdated)
	if err := _PriceFeed.contract.UnpackLog(event, "AssetPriceUpdated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// PriceFeedEthPriceUpdatedIterator is returned from FilterEthPriceUpdated and is used to iterate over the raw logs and unpacked data for EthPriceUpdated events raised by the PriceFeed contract.
type PriceFeedEthPriceUpdatedIterator struct {
	Event *PriceFeedEthPriceUpdated // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *PriceFeedEthPriceUpdatedIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(PriceFeedEthPriceUpdated)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(PriceFeedEthPriceUpdated)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *PriceFeedEthPriceUpdatedIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *PriceFeedEthPriceUpdatedIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// PriceFeedEthPriceUpdated represents a EthPriceUpdated event raised by the PriceFeed contract.
type PriceFeedEthPriceUpdated struct {
	Price     *big.Int
	Timestamp *big.Int
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterEthPriceUpdated is a free log retrieval operation binding the contract event 0xb4f35977939fa8b5ffe552d517a8ff5223046b1fdd3ee0068ae38d1e2b8d0016.
//
// Solidity: event EthPriceUpdated(uint256 price, uint256 timestamp)
func (_PriceFeed *PriceFeedFilterer) FilterEthPriceUpdated(opts *bind.FilterOpts) (*PriceFeedEthPriceUpdatedIterator, error) {

	logs, sub, err := _PriceFeed.contract.FilterLogs(opts, "EthPriceUpdated")
	if err != nil {
		return nil, err
	}
	return &PriceFeedEthPriceUpdatedIterator{contract: _PriceFeed.contract, event: "EthPriceUpdated", logs: logs, sub: sub}, nil
}

// WatchEthPriceUpdated is a free log subscription operation binding the contract event 0xb4f35977939fa8b5ffe552d517a8ff5223046b1fdd3ee0068ae38d1e2b8d0016.
//
// Solidity: event EthPriceUpdated(uint256 price, uint256 timestamp)
func (_PriceFeed *PriceFeedFilterer) WatchEthPriceUpdated(opts *bind.WatchOpts, sink chan<- *PriceFeedEthPriceUpdated) (event.Subscription, error) {

	logs, sub, err := _PriceFeed.contract.WatchLogs(opts, "EthPriceUpdated")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(PriceFeedEthPriceUpdated)
				if err := _PriceFeed.contract.UnpackLog(event, "EthPriceUpdated", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseEthPriceUpdated is a log parse operation binding the contract event 0xb4f35977939fa8b5ffe552d517a8ff5223046b1fdd3ee0068ae38d1e2b8d0016.
//
// Solidity: event EthPriceUpdated(uint256 price, uint256 timestamp)
func (_PriceFeed *PriceFeedFilterer) ParseEthPriceUpdated(log types.Log) (*PriceFeedEthPriceUpdated, error) {
	event := new(PriceFeedEthPriceUpdated)
	if err := _PriceFeed.contract.UnpackLog(event, "EthPriceUpdated", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
