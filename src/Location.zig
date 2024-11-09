/// Direction enum
pub const FaceE = enum {
    Up,
    Down,
    Left,
    Right,
};

/// Direction
pub const Face = struct {
    /// Current direction (default: right)
    face: FaceE = FaceE.Right,

    /// Initialization
    pub fn init(face: FaceE) Face {
        return Face{
            .face = face,
        };
    }

    /// Direction opposite to current direction
    pub fn opposite(self: *Face) FaceE {
        return switch (self.face) {
            FaceE.Up => FaceE.Down,
            FaceE.Down => FaceE.Up,
            FaceE.Right => FaceE.Left,
            FaceE.Left => FaceE.Right,
        };
    }
};

/// Location
pub const Location = struct {
    x: i32 = undefined,
    y: i32 = undefined,

    /// Initialization
    pub fn init(
        x: i32,
        y: i32,
    ) Location {
        return Location{
            .x = x,
            .y = y,
        };
    }

    /// Move location based on current location and movement
    pub fn moveTo(
        self: Location,
        face: FaceE,
    ) Location {
        var f = self;
        switch (face) {
            FaceE.Up => f.y -= 1,
            FaceE.Down => f.y += 1,
            FaceE.Left => f.x -= 1,
            FaceE.Right => f.x += 1,
        }
        return f;
    }

    /// Is current location inbounds
    pub fn inBounds(
        self: Location,
        max_width: i32,
        max_height: i32,
    ) bool {
        return (self.x > -1) and //
            (self.x < max_width) and //
            (self.y > -1) and //
            (self.y < max_height);
    }

    /// Compare two locations
    pub fn equal(
        self: Location,
        value: Location,
    ) bool {
        if ((self.x == value.x) and //
            (self.y == value.y))
        {
            return true;
        } else {
            return false;
        }
    }
};
