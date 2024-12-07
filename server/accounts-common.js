Meteor.startup(() => {
  if (Meteor.isServer) {
    import { AccountsCommon } from 'meteor/accounts-base';

    Accounts.config({
      loginExpirationInDays: process.env.ACCOUNTS_COMMON_LOGIN_EXPIRATION_IN_DAYS || 90,
    });

    Meteor.settings.packages.accounts.sendVerificationEmail = process.env.ACCOUNTS_SEND_VERIFICATION_EMAIL === "true";
  }
});
