/*
 * Copyright (c) 2021-2023 Arculus Holdings, L.L.C. All Rights Reserved.
 *
 * This software is confidential and proprietary information of Arculus Holdings, L.L.C.
 * All use and disclosure to third parties is subject to the confidentiality provisions
 * of the license agreement accompanying the associated software.
 *
 * This copyright notice and disclaimer shall be included with all copies of this
 * software used in derivative works.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS OF THIS SOFTWARE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THIS SOFTWARE OR THE USE, MODIFICATION, DISTRIBUTION, OR OTHER DEALINGS IN THIS
 * SOFTWARE OR ITS DERIVATIVES.
 */

 /**
  * @file  csdk.h
  *
  * @brief Header file linked to the csdk.c file. Public API
  *
  * Notes: XXXXXXRequest  Usually provides the bytes to send, the Client sends bytes over NFC
  * Notes: XXXXXXResponse Usually used to parse response bytes provided by client
  */

#ifndef __CSDK_H__
#define __CSDK_H__

#ifdef CSDK_EXPORTS
#define CSDK_API __declspec(dllexport)
#else
#define CSDK_API extern
#endif

#undef AFX_DATA
#define AFX_DATA AFX_EXT_DATA

#undef AFX_DATA
#define AFX_DATA

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include "csdk_types.h"

/**
 * @brief Allocates and populates a Wallet struct that must be freed by calling WalletFree()
 * @return AppletObj wallet pointer
 */
CSDK_API AppletObj* WalletInit();

/**
 * @brief Frees memory allocated for wallet
 * @param wallet AppletObj wallet structure containing list of pointers(ex: apdu commands...etc)
 */
CSDK_API int WalletFree(AppletObj *wallet);

/**
 * @brief Create an initialize session request object to send to the card, must be called after WalletInit()
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[out] len of the request session object returned
 * @return Pointer to the InitSession request object
 */
CSDK_API uint8_t *WalletInitSessionRequest(AppletObj *wallet, size_t *len);


/**
 * @brief Processes the initialize session request object from WalletInitSessionRequest after the card has processed it
 *        Must be successful (CSDK_OK returned) in order to call other CSDK_API calls
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the card
 * @param[in] responseLength : length in bytes of the response
 * @return CSDK_OK on success, ERR_* error code on failure.
 */
CSDK_API int WalletInitSessionResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength);

/**
 * @brief Parse RC to give the right message associated to the reasonCode
 *
 * @param RC reason code
 * @param[out] message pointer to byte array, to fill out the error message regarding the reason code
 * @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
 * @return CSDK_API WalletErrorMessage CSDK_OK or CSDK_ERR_*
 */
CSDK_API int WalletErrorMessage(int rc, const char **message, size_t *len);

/**
 * @brief Generate Seed From a mnemonic sentence.
 *
 * @param wallet AppletObj wallet structure containing list of pointers(ex: apdu commands...etc)
 * @param[in] mnemonicSentence byte array (pointer) containing concatenated words, space separated
 * @param mnemonicSentenceLength Length of provided words data
 * @param[in] passphrase (OPTIONAL: put to null) byte array (pointer) containing passphrase
 * @param passphraseLength (OPTIONAL: put to 0) Length of provided passphrase data
 * @param[out] seedLength of seed filled in as part of the response when calling this function
 * @return seed pointer to a byte array.
 */
CSDK_API uint8_t* WalletSeedFromMnemonicSentence(AppletObj *wallet, const unsigned char *mnemonicSentence, const size_t mnemonicSentenceLength,
                                      const unsigned char *passphrase, const size_t passphraseLength, size_t *seedLength);

/**
 * @brief Seed Create Wallet. Used to initialize the Hardware Wallet
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
 * @param[in] nbrOfWords the number of mnemonic words to create the wallet. 12 to 24, if set to 0 , default value is 12;
 * @return CSDK_API command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
 */
CSDK_API uint8_t* WalletSeedCreateWalletRequest(AppletObj *wallet, size_t *len, size_t nbrOfWords);

/**
 * @brief Create Wallet. Used to initialize the Hardware Wallet
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @param[out] mnemonicSentenceLength: length of the returnd mnemonic words
 * @return CSDK_API WalletCreateWalletResponse - mnemonic words non NULL terminated string
 */
CSDK_API uint8_t* WalletSeedCreateWalletResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength, size_t *mnemonicSentenceLength);

/**
 * @brief Init Recover wallet
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param nbrOfWords amount of recovery words
 * @return command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
*/
CSDK_API uint8_t* WalletInitRecoverWalletRequest(AppletObj *wallet, size_t nbrOfWords, size_t *len);

/**
 * @brief Init Recover wallet
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @return CSDK_API WalletInitRecoverWalletResponse CSDK_OK or ERR_*
 */
CSDK_API int WalletInitRecoverWalletResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength);


/**
 * @brief Get Firmware Version Request
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
 * @return command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
 */
CSDK_API uint8_t *WalletGetFirmwareVersionRequest(AppletObj *wallet, size_t *len);

/**
 * @brief Get Firmware Version Response
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @param[out] versionLength: the length of the Firmware Version
 * @return the Version or NULL in case of error
 */
CSDK_API uint8_t* WalletGetFirmwareVersionResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength, size_t *versionLength);

/**
* @brief Seed Finish Recover Wallet
*
* @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
* @param[in] seed pointer to
* @param[in] seedLength
* @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
* @return command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
*/
CSDK_API uint8_t* WalletSeedFinishRecoverWalletRequest(AppletObj *wallet, const unsigned char *seed, const size_t seedLength, size_t *len);

/**
 * @brief Parse response to Finish Recover Wallet
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @return CSDK_API WalletSeedFinishRecoverWalletResponse CSDK_OK or ERR_*
 */
CSDK_API int WalletSeedFinishRecoverWalletResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength);


/**
* @brief Get GGUID of the wallet. Select wallet needs to be called prior to this.
*
* @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
* @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
* @return The APDU command to send to the card to execute a create wallet
*/
CSDK_API uint8_t* WalletGetGGUIDRequest(AppletObj *wallet, size_t *len);

/**
 *  @brief Parse the response of Get GGUID of the wallet.
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @param[out] GGUIDLength: the length of the GGUID
 * @return the GGUID or NULL in case of error
 */
CSDK_API uint8_t* WalletGetGGUIDResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength, size_t *GGUIDLength);

/**
* @brief Select Wallet applet
*
* @param wallet AppletObj wallet structure containing list of pointers(ex: apdu commands...etc)
* @return command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
*/
CSDK_API uint8_t* WalletSelectWalletRequest(AppletObj *wallet, const uint8_t *aid, size_t *len);

/**
 * @brief Parse response to Wallet Select response
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @return resps pointer to OperationSelectResponse* struct, will be filled by the function after parsing provided response
 */
CSDK_API OperationSelectResponse* WalletSelectWalletResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength);


/**
 * @brief  Verify PIN
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] pin and pinLen
 * @param[out] command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
 * @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
 * @return CSDK_API WalletVerifyPINRequest or NULL in case of error
 */
CSDK_API uint8_t* WalletVerifyPINRequest(AppletObj *wallet, const uint8_t *pin, size_t pinLen, size_t *len);

/**
* @brief parse response from comm and verify a pin, if wrong pin, the nbr of remaining tries can be shown to user (see params)
*
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
* @param[in] response : Response to be parsed, sent by the client
* @param[in] responseLength : length in bytes of the response
* @param[out] nbrOfTries : Number of tries remaining (3 by default, less in case of one or more, wrong pin in a row). At 0, the pin is blocked
* @return CSDK_OK in case of success, ERR_WRONG_PIN (-108) in case of wrong pin, then you can announce the number of tries remaining (see nbrOfTries Param)
*/
CSDK_API int WalletVerifyPINResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength, size_t *nbrOfTries);

/**
 * @brief Store Data PIN
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param pin and pinlen
 * @param[out] command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
 * @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
 * @return CSDK_API WalletStoreDataPINRequest or NULL in case of error
 */
CSDK_API uint8_t* WalletStoreDataPINRequest(AppletObj *wallet, const uint8_t *pin, size_t pinLen, size_t *len);

/**
 * @brief Parse response to Store Data PIN
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @return CSDK_API WalletStoreDataPINResponse CSDK_OK or ERR_*
 */
CSDK_API int WalletStoreDataPINResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength);

/**
* @brief Function used to retrieve Public Key of a certain given path.
*
* @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
* @param[in] bipPath Path in ascii (and decimal for elts): ex: "m/44h/60h/0h/0/0" or "m/44'/60'/0'/0/0"
* @param[in] bipPathLength The length of the BIP path
* @param[in] curve Curve to use: (MSB: 1=secp256k1, 2=ed25519, 3=nist256p1, 4=ed25519 Cardano, 5=sr25519,  LSB: variation)
* @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
* @return The command to be sent to the card
*/
CSDK_API uint8_t* WalletGetPublicKeyFromPathRequest(AppletObj *wallet, const uint8_t *bipPath, size_t bipPathLength, uint16_t curve, size_t *len);

/**
 * @brief Function used to retrieve Public Key of a certain path. This command is a Get Data (INS : 0xCA) with tag BFC5]
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : response from the card when passed a request generated from WalletGetPublicKeyFromPathRequest
 * @param[in] responseLength : length in bytes of the response
 * @return The extended key (pubkey + chaincode) or NULL in case of error
 */
CSDK_API ExtendedKey* WalletGetPublicKeyFromPathResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength);

/**
 * @brief Reset Wallet. reset the wallet on card
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
 * @return CSDK_API command pointer to a char*. The function with fill this "char array" with the appropriate APDU command to be sent by the client
 */
CSDK_API uint8_t* WalletResetWalletRequest(AppletObj *wallet, size_t *len);

/**
 * @brief Reset Wallet. reset the wallet on card
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @return CSDK_API return CSDK_OK or ERR_*
 */
CSDK_API int WalletResetWalletResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength);

/**
  * @brief Create command for signing requested hash
  *
  * DEPRECATED: Use WalletSignRequest
  *
  * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
  * @param[in] bip_path bip_path Path in ascii (and decimal for elts): ex: "m/44h/60h/0h/0/0" or "m/44'/60'/0'/0/0"
  * @param[in] bip_path_length The length of the BIP path
  * @param[in] curve Curve to use: (MSB: 1=secp256k1, 2=ed25519, 3=nist256p1, 4=ed25519 Cardano, 5=sr25519,  LSB: variation)
  * @param[in] algorithm Hash Algorithm to use: 0 default/undefined, 1 ECDSA, 2 EDDSA, 3 EC Schnorr, 4 Ristretto, 5 Cardano
  * @param[in] hash pointer to the hash to be signed
  * @param[in] hash_length length of the hash alg
  * @param[out] len the function fill out this value with the length of the command (or response for functions handling responses)
  * @return Pointer to the command or NULL in case of error
  */
CSDK_API uint8_t* WalletSignHashRequest(AppletObj *wallet, const uint8_t *bip_path, size_t bip_path_length,
                                        uint16_t curve, uint8_t algorithm,
                                        const uint8_t *hash, const size_t hash_length, size_t *len);

/**
  * @brief Create command for signing requested hash for large hash payloads
  *
  * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
  * @param[in] bipPath ByteVector of BIP Path in ascii (and decimal for elts): ex: "m/44h/60h/0h/0/0" or "m/44'/60'/0'/0/0"
  * @param[in] curve Curve to use: (MSB: 1=secp256k1, 2=ed25519, 3=nist256p1, 4=ed25519 Cardano, 5=sr25519,  LSB: variation)
  * @param[in] algorithm Hash Algorithm to use: 0 default/undefined, 1 ECDSA, 2 EDDSA, 3 EC Schnorr, 4 Ristretto, 5 Cardano
  * @param[in] hash pointer ByteVector that contains the hash to be signed
  * @param[out] apdus Pointer to APDUSequence which contains ByteVectors of extended APDU or chain of normal APDUs
  * @return CSDK_OK on success
  */
CSDK_API int WalletSignRequest(AppletObj *wallet,
                                   ByteVector *bipPath,
                                   uint16_t curve, uint8_t algorithm,
                                   ByteVector *hash,
                                   APDUSequence **apdus);


/**
 * @brief Process the sign hash response
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[in] response : Response to be parsed, sent by the client
 * @param[in] responseLength : length in bytes of the response
 * @param[out] signedHashLength : length in bytes of the signed Hash
 * @return Pointer to the hash signature, NULL in case of error
 */
CSDK_API uint8_t* WalletSignHashResponse(AppletObj *wallet, const uint8_t *response, size_t responseLength, size_t *signedHashLength);

/**
 * @brief Get the Capabilities of the Card connected to the NFC Session
 *    Requires a Select Wallet to have been performed.
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param[out] apdus Pointer to WalletCapabilities struct describing card capabilities
 * @return CSDK_OK on success
 */
CSDK_API int WalletGetCapabilities(AppletObj *wallet, WalletCapabilities *capabilities);

/**
 * @brief Use APDU chaining over extended APDU's
 *    By default the CSDK will use extended APDU's by default if supported by card
 *    This is used to use chained APDU's vs extended APDU's
 *
 * @param wallet AppletObj context object created by WalletInit() used in all subsequent API calls
 * @param useAPDUChaining true to use APDU chaining
 * @return CDSK_OK on success CDSK_ERR_* on error
 */
CSDK_API int WalletUseAPDUChaining(AppletObj *wallet, bool useAPDUChaining);

// Helper functions for Android to get PubKey and Chain Code
CSDK_API uint8_t* ExtendedKey_getPubKey(ExtendedKey *extendedKey, size_t *len);
CSDK_API uint8_t* ExtendedKey_getChainCode(ExtendedKey *extendedKey, size_t *len);

#endif
