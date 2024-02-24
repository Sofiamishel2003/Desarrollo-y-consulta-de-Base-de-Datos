import csv
import traceback
import psycopg2
from psycopg2 import sql
from datetime import datetime

def convert_date_format(date_str):
    # Convierte una cadena de fecha 'MM/DD/YYYY HH:MI' a 'YYYY-MM-DD HH:MI:SS'
    try:
        return datetime.strptime(date_str, '%m/%d/%Y %H:%M').strftime('%Y-%m-%d %H:%M:%S')
    except ValueError:
        return None

# Función para probar la conexión a la base de datos
def testear_conexion():
    try:
        with psycopg2.connect(dbname="futbol", user="postgres", password="Renacuajo1", host="127.0.0.1", port="5432") as conn:
            print("Se conectó a la base de datos exitosamente.")
    except psycopg2.OperationalError as e:
        print(f"Ocurrió un error al intentar conectarse a la base de datos: {e}")
        traceback.print_exc()

# Función para contar las columnas de un archivo CSV
def count_columns(archivo_csv):
    try:
        with open(archivo_csv, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            header = next(csvreader)
            return len(header)
    except Exception as e:
        print(f"Error al contar columnas: {e}")
        traceback.print_exc()
        return 0

# Función para escribir los datos de los archivos CSV a la base de datos
def writer(tabla_db, archivo_csv):
    try:
        conn = psycopg2.connect(dbname="futbol", user="postgres", password="Renacuajo1", host="127.0.0.1", port="5432")
        cur = conn.cursor()
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
                # Asumiendo que la columna de fecha está en el índice 3 en el archivo de 'games'
                if tabla_db == 'games' or tabla_db == 'teamstats':
                    row[3] = convert_date_format(row[3])
                row = [None if val.lower() == 'na' else val for val in row]
                batch.append(row)
                if len(batch) >= 1000:  # Insertar en lotes de 1000 filas
                    cur.executemany(sql_insert, batch)
                    batch = []
            if batch:  # Insertar el último lote si es que hay
                cur.executemany(sql_insert, batch)
        conn.commit()  # Confirmar los cambios
        print(f'Datos insertados en la tabla {tabla_db} exitosamente.')
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Error al insertar datos en {tabla_db}: {e}")
        traceback.print_exc()
        if conn is not None:
            conn.rollback()
            conn.close()

# Probar conexión
testear_conexion()

# Llamadas a la función 'writer' para cada archivo CSV
tablas_y_archivos = [
    ("leagues", "csvFiles/leagues.csv"),
    ("players", "csvFiles/players.csv"),
    ("teams", "csvFiles/teams.csv"),
    ("games", "csvFiles/games.csv"),
    ("appearances", "csvFiles/appearances.csv"),
    ("shots", "csvFiles/shots.csv"),
    ("teamstats", "csvFiles/teamstats.csv")
]

for tabla, archivo in tablas_y_archivos:
    writer(tabla, archivo)
