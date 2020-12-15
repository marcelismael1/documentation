from mongoengine import *
import datetime, os
from bson.objectid import ObjectId


# Mongo
mongodb = 'mongodb://mongodb'
mongoport = 27017
mongodatabase = 'aimm_cs'
collection = 'android'

connect(
    db=mongodatabase,
    host=mongodb,
    port=mongoport
)


class Android(Document):
    rev_pld_var = FloatField()
    src_port = IntField()
    pld_distinct = IntField()
    rev_hdr_ccnt = ListField()
    bytes_out = IntField()
    hdr_mean = StringField()
