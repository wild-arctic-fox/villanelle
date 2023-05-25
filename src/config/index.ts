import dotenv from "dotenv";

dotenv.config();

const processEnv = process.env;
const configuration = {
  applicationName: processEnv.APPLICATION_NAME || "express-server-pj",
  env: processEnv.NODE_ENV || "development",
  isProduction: processEnv.NODE_ENV === "production",
  timeZone: processEnv.TIMEZONE || "UTC",
  workingPort: (processEnv.PORT && parseInt(processEnv.PORT, 10)) || 7410,
};

export const config = Object.freeze(configuration);
