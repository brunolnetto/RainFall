from fastapi import FastAPI
from sqlalchemy.orm import sessionmaker

from models import Base
from database import engine

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello World"}


Session = sessionmaker(bind=engine)

# Create the tables
Base.metadata.create_all(engine)