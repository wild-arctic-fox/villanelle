import express from "express";
import { Express, Request, Response } from "express";
import { config } from "./config/index";
import cors from "cors";

const app: Express = express();

async function startServer() {
  process.on("unhandledRejection", (reason, p) => {
    console.error(JSON.stringify({ p, reason }));
  });

  process.on("uncaughtException", (error) =>
    console.error(JSON.stringify(error))
  );

  app.use(
    cors({
      origin: "*",
    })
  );

  app.use(express.json({ limit: "50mb" }));

  app.get("/", (_req: Request, res: Response) => {
    res.send(`Date: ${new Date()}
      Enviroment: ${config.env}`);
  });

  app.listen(config.workingPort, () => {
    console.info(
      `${config.applicationName} server started at port ${config.workingPort} in ${config.env} environment`
    );
  });
}

startServer();
