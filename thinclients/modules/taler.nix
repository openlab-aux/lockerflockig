{
  config,
  pkgs,
  lib,
  ...
}:
let
  CURRENCY = "OLA";
  FIAT_CURRENCY = "EUR";
in
{
  environment.systemPackages = lib.mkAfter [ pkgs.taler-wallet-core ];
  # Add your configuration here
  services.taler.exchange = {
    enable = true;
    openFirewall = true;
    debug = true;
    package = pkgs.taler-exchange.overrideAttrs (old: { src = pkgs.fetchgit {
      url = "ssh://git@git.taler.net/taler/exchange.git";
      rev = "v1.6.16";
      fetchSubmodules = true;
      hash = lib.fakeHash;
    }; });
    denominationConfig = ''
      [coin_OLA_n1_t1789756177]
      VALUE = OLA:0.01
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n2_t1789756177]
      VALUE = OLA:0.02
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n3_t1789756177]
      VALUE = OLA:0.04
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n4_t1789756177]
      VALUE = OLA:0.08
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n5_t1789756177]
      VALUE = OLA:0.16
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n6_t1789756177]
      VALUE = OLA:0.32
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n7_t1789756177]
      VALUE = OLA:0.64
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n8_t1789756177]
      VALUE = OLA:1.28
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n9_t1789756177]
      VALUE = OLA:2.56
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n10_t1789756177]
      VALUE = OLA:5.12
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n11_t1789756177]
      VALUE = OLA:10.24
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n12_t1789756177]
      VALUE = OLA:20.48
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n13_t1789756177]
      VALUE = OLA:40.96
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA

      [coin_OLA_n14_t1789756177]
      VALUE = OLA:81.92
      DURATION_WITHDRAW = 7 days
      DURATION_SPEND = 2 years
      DURATION_LEGAL = 6 years
      FEE_WITHDRAW = OLA:0
      FEE_DEPOSIT = OLA:0.01
      FEE_REFRESH = OLA:0
      FEE_REFUND = OLA:0
      RSA_KEYSIZE = 2048
      CIPHER = RSA
    '';
    settings = {
      exchange = {
        MASTER_PUBLIC_KEY = "9R4RC8V9RRXNFVS9K0D37FRTDXG7J1STH0W1YFHTYX68Q9325XX0";
        inherit CURRENCY;
        CURRENCY_ROUND_UNIT = "0.01";
      };
    };
  };

  services.taler.merchant = {
    enable = true;
    openFirewall = true;
    settings.merchant-exchange-test = {
           EXCHANGE_BASE_URL = "http://exchange:8081/";
           MASTER_KEY = "2TQSTPFZBC2MC4E52NHPA050YXYG02VC3AB50QESM6JX1QJEYVQ0";
           inherit CURRENCY;
         };
  };

  services.taler.settings = {
    taler = {
      inherit CURRENCY;
    };
  };


}
