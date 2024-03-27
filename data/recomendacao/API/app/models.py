from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

# Define a template model for tests
class sugestoes(Base):
    __tablename__ = 'sugestoes'

    id = Column(Integer, primary_key=True)
    name = Column(String)
    age = Column(Integer)

