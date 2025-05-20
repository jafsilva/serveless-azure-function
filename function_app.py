import azure.functions as func
import datetime
from zoneinfo import ZoneInfo
import logging

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="home")
def home(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')
    data_hora_atual = datetime.datetime.now(ZoneInfo("America/Sao_Paulo")).strftime('%Y-%m-%d %H:%M:%S')
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        return func.HttpResponse(f"Hello, {name}. This HTTP triggered function executed successfully.\nHora atual: {data_hora_atual}")
    else:
        return func.HttpResponse(
             f"This HTTP triggered function executed successfully.\nHora atual: {data_hora_atual}",
             status_code=200
        )