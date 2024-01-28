from django.contrib import admin
from .models import Store, Sale, Stock, Product, Supplier, Wholesale, Item


admin.site.register(Stock)
admin.site.register(Sale)
admin.site.register(Item)
admin.site.register(Supplier)
admin.site.register(Store)
admin.site.register(Product)
admin.site.register(Wholesale)
