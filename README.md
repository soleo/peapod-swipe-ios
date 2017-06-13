# Peapod Swipe

Peapod Swipe App for Business User's Product Preference.

### API Definition

#### GET Product List
```
GET /api/v1/organization/1/recommendations?num=50
{
    [
    "products": [
      {
        "productId": 136044,
        "name": "Apples Honeycrisp",
        "images": {
          "small": "https://i5.peapod.com/c/DG/DG5VB.jpg",
          "medium": "https://i5.peapod.com/c/68/68LC0.jpg",
          "large": "https://i5.peapod.com/c/FV/FVFH4.jpg",
          "xlarge": "https://i5.peapod.com/c/KK/KK5G3.jpg"
        }
      }
    ]
}
```

#### POST Preference
```
POST /api/v1/organization/1/user/1/vote
{
    "productId": 136044,
    "like": true
}
```
