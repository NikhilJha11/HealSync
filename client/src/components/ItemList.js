import React from "react";
import { Button, Card } from "antd";
import { useDispatch } from "react-redux";
const ItemList = ({ item }) => {
  const dispatch = useDispatch();
  //update cart handler
  const handleAddTOCart = () => {
    dispatch({
      type: "ADD_TO_CART",
      payload: item,
    });
  };
  const { Meta } = Card;
  return (
    <div>
      <Card
        style={{ width: 150, marginBottom: 20 }}
        cover={<img alt={item.name} src={item.image} style={{ height: 100 }} />}
      >
        <Meta title={item.name} />
        <div className="item-button">
          <Button onClick={() => handleAddTOCart()}>Add</Button>
        </div>
      </Card>
    </div>
  );
};

export default ItemList;