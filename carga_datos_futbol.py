import psycopg2
from psycopg2 import sql #instalar la libreria con "pip install psycopg2"
from psycopg2.extensions import AsIs

# Función para probar la conexión a la base de datos
def testear_conexion():
    try:
        with psycopg2.connect(dbname="futbol", user="postgres", password="Renacuajo1", host="127.0.0.1", port="5432") as conn:
            print("Se conectó a la base de datos exitosamente.")
    except psycopg2.OperationalError as e:
        print(f"Ocurrió un error al intentar conectarse a la base de datos: {e}")

# Función para contar las columnas de un archivo CSV
def count_columns(archivo_csv):
    try:
        with open(archivo_csv, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            header = next(csvreader)
            return len(header)
    except Exception as e:
        print(f"Error al contar columnas: {e}")
        return 0

# Función para escribir los datos de los archivos CSV a la base de datos
def writer(tabla_db, archivo_csv):
    try:
        with psycopg2.connect(dbname="FutbolStats_Proy1", user="postgres", password="Renacuajo1", host="127.0.0.1", port="5432") as conn:
            with conn.cursor() as cur:
                num_columns = count_columns(archivo_csv)
                placeholders = ', '.join(['%s' for _ in range(num_columns)])
                sql_insert = sql.SQL('INSERT INTO {} VALUES ({})').format(
                    sql.Identifier(tabla_db),
                    sql.SQL(placeholders)
                )

                with open(archivo_csv, 'r') as csvfile:
                    csvreader = csv.reader(csvfile)
                    next(csvreader)  # Saltar la cabecera
                    batch = []
                    for row in csvreader:
                        row = [None if val.lower() == 'na' else val for val in row] 
                        batch.append(row)
                        if len(batch) >= 1000:  # Insertar en lotes de 1000 filas
                            cur.executemany(sql_insert, batch)
                            batch = []
                    if batch:  # Insertar el último lote si es que hay
                        cur.executemany(sql_insert, batch)
                print(f'Datos insertados en la tabla {tabla_db} exitosamente.')
    except Exception as e:
        print(f"Error al insertar datos en {tabla_db}: {e}")

# Probar conexión
testear_conexion()

# Llamadas a la función 'writer' para cada archivo CSV
tablas_y_archivos = [
    ("leagues", "leagues.csv"),
    ("players", "players.csv"),
    ("teams", "teams.csv"),
    ("games", "games.csv"),
    ("appearances", "appearances.csv"),
    ("shots", "shots.csv"),
    ("teamstats", "teamstats.csv")
]

for tabla, archivo in tablas_y_archivos:
    writer(tabla, archivo)
