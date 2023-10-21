import React, { useState, useEffect } from "react";
import DefaultLayout from "./../components/DefaultLayout";
import axios from "axios";
import { Row, Col } from "antd";
import { useDispatch } from "react-redux";
import ItemList from "../components/ItemList";
const Homepage = () => {
  const [itemsData, setItemsData] = useState([]);
  const [selecedCategory, setSelecedCategory] = useState("Analgesics");
  const categories = [
    {
      name: "Analgesics",
      imageUrl: "https://img.freepik.com/free-vector/isometric-gastroenterology-composition-with-view-medication-with-tubes-pills-illustration_1284-63536.jpg?w=2000",

    },
    {
      name: "Antibiotics",
      imageUrl: "https://img.freepik.com/premium-vector/pills-liquids-medicine-children-kawaii-doodle-flat-vector-illustration_609998-86.jpg?w=2000",
    },
    {
      name: "Antacids",
      imageUrl: "https://media.istockphoto.com/id/1277447239/vector/opened-pill-drug-bottle-with-some-pills-capsules-laying-down-prescription-medicine-container.jpg?s=612x612&w=0&k=20&c=ShKwi3MWCyimvGS1U18E4k9l1hchCp6aUDzqs3TJkqg=",
    },
    {
      name: "Tests",
      imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT6QDwD_Gqj_oXg8GKkedQRjDCxRcXr7oFEcjlT9jDGtkR8UNC6uTCeRyHv0B5jhiRFK8w&usqp=CAU",
    },
   
  ];
  const dispatch = useDispatch();

  //useEffect
  useEffect(() => {
    const getAllItems = async () => {
      try {
        dispatch({
          type: "SHOW_LOADING",
        });
        const { data } = await axios.get("/api/items/get-item");
        setItemsData(data);
        dispatch({ type: "HIDE_LOADING" });
        console.log(data);
      } catch (error) {
        console.log(error);
      }
    };
    getAllItems();
  }, [dispatch]);
  return (
    <DefaultLayout>
      <div className="d-flex">
        {categories.map((category) => (
          <div
            key={category.name}
            className={`d-flex category ${
              selecedCategory === category.name && "category-active"
            }`}
            onClick={() => setSelecedCategory(category.name)}
          >
            <h4>{category.name}</h4>
            <img
              src={category.imageUrl}
              alt={category.name}
              height="40"
              width="60"
            />
          </div>
        ))}
      </div>
      <Row>
        {itemsData
          .filter((i) => i.category === selecedCategory)
          .map((item) => (
            <Col xs={24} lg={6} md={12} sm={6}>
              <ItemList key={item.id} item={item} />
            </Col>
          ))}
      </Row>
    </DefaultLayout>
  );
};

export default Homepage;