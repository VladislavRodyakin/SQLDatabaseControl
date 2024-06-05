from django.shortcuts import render
from django.http import HttpResponse
from django.shortcuts import render, redirect
from .models import *

# Create your views here.
def home(request):
    return render(request, "home.html", context={"current_tab": "home"})


def readers(request):
    return render(request, "readers.html", context={"current_tab": "readers"})


def books(request):
    return render(request, "books.html", context={"current_tab": "books"})


def checkouts(request):
    return render(request, "checkouts.html", context={"current_tab": "checkouts"})


def returns(request):
    return render(request, "returns.html", context={"current_tab": "returns"})


def readers_tab(request):
    if request.method == 'GET':
        readers=reader.objects.all()
        return render(request, 'readers.html', context={"current_tab": "readers", "readers": readers})
    else:
        query = request.POST['query']
        readers = reader.objects.raw("select id, reader_name, reader_contact, reader_address from lims_app_reader \
                                    where reader_name like '%" + query + "%'")
        return render(request, 'readers.html', context={"current_tab": "readers", "readers": readers, "query": query})
        


def save_reader(request):
    reader_item = reader(
        reader_name=request.POST['reader_name'],
        reader_contact=request.POST['reader_contact'],
        reader_address=request.POST['reader_address'],
        is_active=True
    )
    reader_item.save()
    return redirect('/readers')