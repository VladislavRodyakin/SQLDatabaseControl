from django.db import models

# Create your models here.
class reader(models.Model):
    def __str__(self) -> str:
        return self.reader_name
    reader_name = models.CharField(max_length=200)
    reader_contact = models.CharField(max_length=200)
    reader_address = models.TextField()
    is_active=models.BooleanField(default=True)
    #reference_id = models.CharField(max_length=200)