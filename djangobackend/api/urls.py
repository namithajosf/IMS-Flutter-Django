from django.urls import path, include
from api import views

urlpatterns = [
    path('login/', views.login, name='login'),
    path('stores/', views.StoreList.as_view(), name='stores'),
    path('sales/', views.SaleList.as_view(), name='sales'),
    path('wholesales/', views.WholesaleList.as_view(), name='wholesales'),

    path('sale_items/', views.ItemList.as_view(), name='items'),
    path('wholesale_items/', views.WholesaleItemsList.as_view(), name='items'),

    path('add_sales/', views.add_sales, name='add_sales'),
    path('add_products/', views.add_products, name='add_products'),
    path('products/<str:name>/', views.get_product, name='get_product'),
    path('products/<int:pk>/', views.delete_product, name='delete_product'),
    path('update_stock/<int:pk>/', views.update_product_stock,
         name='update_product_stock'),
    path('products/', views.ProductList.as_view(), name='products'),
    path('users/', views.UserList.as_view(), name='users'),
    path('users/<int:pk>/', views.delete_user, name='delete_users'),
    path('add_users/', views.add_users, name='add_users'),
    path('stocks/', views.StockList.as_view(), name='stocks'),
    path('stocks/<int:pk>/', views.edit_store_stock, name='edit_store'),
    path('suppliers/', views.SupplierList.as_view(), name='suppliers'),
    path('add_suppliers/', views.add_suppliers, name='add_suppliers'),
    path('suppliers/<int:pk>/', views.delete_supplier, name='delete_supplier'),
    path('wholesales/', views.WholesaleList.as_view(), name='wholesales'),
    path('sales/<int:pk>/', views.delete_sale, name='delete_sale'),
    path('add_wholesales/', views.add_wholesales, name='add_wholesales'),






]
