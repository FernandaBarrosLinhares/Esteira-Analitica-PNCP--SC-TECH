import zipfile
from pathlib import Path

import src.config as config


def localizar_zip():
    """Localiza o arquivo ZIP dentro da pasta data."""
    pasta_dados = config.PASTA_RAIZ / "data"

    arquivos_zip = list(pasta_dados.glob("*.zip"))

    if not arquivos_zip:
        raise FileNotFoundError(
            f"Nenhum arquivo ZIP encontrado em: {pasta_dados}"
        )

    if len(arquivos_zip) > 1:
        raise RuntimeError(
            f"Há mais de um ZIP em {pasta_dados}. "
            "Deixe somente o arquivo correto ou indique seu nome no código."
        )

    return arquivos_zip[0]


def extrair_arquivos():
    """Extrai os arquivos CSV do ZIP para a pasta data/raw."""
    arquivo_zip = localizar_zip()
    pasta_destino = config.PASTA_RAIZ / "data" / "raw"

    pasta_destino.mkdir(parents=True, exist_ok=True)

    arquivos_esperados = {
        "compras.csv",
        "itens.csv",
        "resultados.csv",
    }

    with zipfile.ZipFile(arquivo_zip, "r") as arquivo:
        arquivos_zip = arquivo.namelist()

        arquivos_encontrados = {
            Path(nome).name
            for nome in arquivos_zip
            if Path(nome).name in arquivos_esperados
        }

        faltantes = arquivos_esperados - arquivos_encontrados

        if faltantes:
            raise FileNotFoundError(
                "Os seguintes arquivos não foram encontrados no ZIP: "
                + ", ".join(sorted(faltantes))
            )

        for nome in arquivos_zip:
            nome_base = Path(nome).name

            if nome_base in arquivos_esperados:
                caminho_destino = pasta_destino / nome_base

                with arquivo.open(nome) as origem:
                    with open(caminho_destino, "wb") as destino:
                        destino.write(origem.read())

                print(f"Extraído: {caminho_destino}")

    print("\nExtração concluída com sucesso.")


if __name__ == "__main__":
    extrair_arquivos()