"""Roda o pipeline completo do projeto, do zero, em sequência."""
import sys
import time
from pathlib import Path
from subprocess import run

PROJECT_ROOT = Path(__file__).resolve().parent
DBT_PROJECT_DIR = PROJECT_ROOT / "dbt_project"
VENV_SCRIPTS = Path(sys.executable).parent

DBT_EXECUTABLE = VENV_SCRIPTS / "dbt.exe"
JUPYTER_EXECUTABLE = VENV_SCRIPTS / "jupyter.exe"


def rodar(comando: list[str], nome: str, cwd: Path = PROJECT_ROOT) -> None:
    """Roda um comando externo e encerra o script se ele falhar."""
    print(f"\n=== {nome} ===")
    inicio = time.time()
    resultado = run(comando, cwd=cwd)
    duracao = time.time() - inicio
    if resultado.returncode != 0:
        print(f"\nFALHOU: {nome} (returncode={resultado.returncode}, {duracao:.0f}s)")
        sys.exit(1)
    print(f"OK: {nome} ({duracao:.0f}s)")


def executar_notebook(caminho: str, nome: str) -> None:
    """Executa um notebook Jupyter do início ao fim e sobrescreve os outputs."""
    rodar(
        [str(JUPYTER_EXECUTABLE), "nbconvert", "--to", "notebook", "--execute", "--inplace", caminho],
        nome,
    )


def main() -> None:
    """Roda o pipeline completo: ingestão, dbt, testes e notebooks, em ordem."""
    inicio_total = time.time()

    rodar([sys.executable, "src/ingest.py"], "Ingestão dos CSVs")
    rodar(
        [str(DBT_EXECUTABLE), "build", "--project-dir", str(DBT_PROJECT_DIR), "--profiles-dir", str(DBT_PROJECT_DIR)],
        "dbt build",
        cwd=DBT_PROJECT_DIR,  # profiles.yml tem caminho relativo ao cwd, nao ao --project-dir
    )
    rodar([sys.executable, "-m", "pytest"], "Testes de ingestão")

    executar_notebook("notebooks/data_quality_report.ipynb", "Data Quality Report")
    executar_notebook("notebooks/analise_exploratoria.ipynb", "Análise Exploratória")

    if "--com-ia" in sys.argv:
        executar_notebook("notebooks/automacao_ia_sentimento.ipynb", "Automação com IA (~25min na 1ª vez)")
    else:
        print("\nPulando Automação com IA. Rode com --com-ia pra incluir (~25min na 1ª vez, depois usa cache).")

    print(f"\nPipeline completo em {(time.time() - inicio_total)/60:.1f} min.")


if __name__ == "__main__":
    main()
